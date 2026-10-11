import {HttpsError, onCall} from "firebase-functions/v2/https";
import {slackConnectionDocument} from "./firestore";
import {setSlackIntegrationConnected} from "./realtime";

export const getSlackConnectionStatus = onCall(async (request) => {
  const uid = request.auth?.uid;

  if (uid == null) {
    throw new HttpsError("unauthenticated", "Please sign in first.");
  }

  const snapshot = await slackConnectionDocument(uid).get();
  const data = snapshot.data();
  const accessToken = data?.accessToken;
  const connected = typeof accessToken === "string" && accessToken.length > 0;

  if (connected) {
    await setSlackIntegrationConnected(uid, true);
  }

  return {
    connected,
    slackUserId: data?.slackUserId ?? null,
    teamName: data?.teamName ?? null,
  };
});

export const disconnectSlack = onCall(async (request) => {
  const uid = request.auth?.uid;

  if (uid == null) {
    throw new HttpsError("unauthenticated", "Please sign in first.");
  }

  await Promise.all([
    slackConnectionDocument(uid).delete(),
    setSlackIntegrationConnected(uid, false),
  ]);
  return {ok: true};
});
