import {randomUUID} from "node:crypto";
import {getAuth} from "firebase-admin/auth";
import {
  FieldValue,
  getFirestore,
  WriteBatch,
} from "firebase-admin/firestore";
import {getDatabase} from "firebase-admin/database";
import {getStorage} from "firebase-admin/storage";
import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {
  oauthStateCollection,
  slackConnectionDocument,
} from "../slack/firestore";
import {setSlackIntegrationConnected} from "../slack/realtime";
import {defaultCubeStatusDefinitions} from "./default_statuses";

const recentAuthWindowSeconds = 5 * 60;

export const deleteCurrentUserAccount = onCall(async (request) => {
  const auth = request.auth;

  if (auth == null) {
    throw new HttpsError("unauthenticated", "Please sign in first.");
  }

  const uid = auth.uid;
  assertRecentAuth(auth.token.auth_time);

  await deleteUserData(uid);
  await getAuth().deleteUser(uid);

  return {ok: true};
});

export async function seedDefaultStatuses(uid: string) {
  const firestore = getFirestore();
  const userDocument = firestore.collection("users").doc(uid);
  const statusCollection = userDocument.collection("status_presets");
  const existingSnapshot = await statusCollection.get();
  const batch = firestore.batch();
  const existingByFace = new Map<string, FirebaseFirestore.DocumentSnapshot>();
  const keptStatusIds = new Set<string>();

  existingSnapshot.docs.forEach((document) => {
    const cubeFace = document.data().cubeFace;

    if (typeof cubeFace === "string" && cubeFace.length > 0) {
      existingByFace.set(cubeFace, document);
    }
  });

  batch.set(userDocument, {
    statusPresetsSeededAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});

  defaultCubeStatusDefinitions.forEach((definition) => {
    const existingDocument = existingByFace.get(definition.cubeFace);
    const statusId = existingDocument?.id ?? randomUUID();
    keptStatusIds.add(statusId);

    batch.set(statusCollection.doc(statusId), {
      ...definition,
      id: statusId,
      isActive: definition.sortOrder === 0,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  deleteExtraStatuses(batch, existingSnapshot.docs, keptStatusIds);
  await Promise.all([
    batch.commit(),
    setSlackIntegrationConnected(uid, false),
  ]);
}

export async function deleteUserData(uid: string) {
  const firestore = getFirestore();

  await Promise.all([
    firestore.recursiveDelete(firestore.collection("users").doc(uid)),
    deletePrivateSlackData(uid),
    getDatabase().ref(`users/${uid}`).remove(),
    getStorage().bucket().deleteFiles({prefix: `users/${uid}/`}),
  ]);
}

function assertRecentAuth(authTime: unknown) {
  if (typeof authTime !== "number") {
    throw new HttpsError("failed-precondition", "Please sign in again.");
  }

  const secondsSinceAuth = Math.floor(Date.now() / 1000) - authTime;

  if (secondsSinceAuth > recentAuthWindowSeconds) {
    throw new HttpsError("failed-precondition", "Please sign in again.");
  }
}

async function deletePrivateSlackData(uid: string) {
  const firestore = getFirestore();
  const oauthStates = await firestore
    .collection(oauthStateCollection)
    .where("uid", "==", uid)
    .get();
  const batch = firestore.batch();

  batch.delete(slackConnectionDocument(uid));
  oauthStates.docs.forEach((document) => batch.delete(document.ref));
  await batch.commit();
}

function deleteExtraStatuses(
  batch: WriteBatch,
  documents: FirebaseFirestore.QueryDocumentSnapshot[],
  keptStatusIds: Set<string>,
) {
  documents.forEach((document) => {
    if (!keptStatusIds.has(document.id)) {
      batch.delete(document.ref);
    }
  });
}

export function logUserDataCleanupError(uid: string, error: unknown) {
  logger.error("User data cleanup failed", {error, uid});
}
