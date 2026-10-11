import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {onValueCreated} from "firebase-functions/v2/database";
import {WebClient} from "@slack/web-api";
import {
  slackConnectionDocument,
  userStatusPresetCollection,
} from "./firestore";
import {
  asTrimmedString,
  orientationFromMqttEvent,
  SlackStatusPayload,
  truncateStatusText,
} from "./status_payload";

const cooldownMs = 15 * 1000;
const validCubeFaces = new Set([
  "faceUp",
  "faceDown",
  "left",
  "right",
  "forward",
  "backward",
]);

export const syncSlackStatusOnMqttEvent = onValueCreated(
  "/users/{uid}/mqtt_events/{eventId}",
  async (event) => {
    const uid = event.params.uid;
    const orientation = orientationFromMqttEvent(event.data.val());

    if (orientation == null) {
      logger.debug("MQTT event skipped: orientation is missing", {uid});
      return;
    }

    const status = await slackStatusFromFirestore(uid, orientation);

    if (status == null) {
      logger.debug("MQTT event skipped: status preset is invalid", {
        orientation,
        uid,
      });
      return;
    }

    const connectionDocument = slackConnectionDocument(uid);
    const connectionSnapshot = await connectionDocument.get();
    const connection = connectionSnapshot.data();
    const accessToken = connection?.accessToken;

    if (typeof accessToken !== "string" || accessToken.length === 0) {
      logger.debug("MQTT event skipped: Slack is not connected", {uid});
      return;
    }

    if (isDuplicateStatus(connection, status)) {
      logger.debug("MQTT event skipped: duplicate Slack status", {uid});
      return;
    }

    if (isCoolingDown(connection)) {
      logger.debug("MQTT event skipped: Slack cooldown is active", {uid});
      return;
    }

    try {
      await setSlackStatus(accessToken, status.text, status.emoji);
      await connectionDocument.set({
        lastError: FieldValue.delete(),
        lastSlackUpdateAt: FieldValue.serverTimestamp(),
        lastStatusEmoji: status.emoji,
        lastStatusText: status.text,
      }, {merge: true});
    } catch (error) {
      logger.error("Slack status update failed", {error, uid});
      await connectionDocument.set({
        lastError: String(error),
        lastErrorAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
  },
);

async function slackStatusFromFirestore(
  uid: string,
  orientation: string,
): Promise<SlackStatusPayload | null> {
  if (!validCubeFaces.has(orientation)) {
    return null;
  }

  const snapshot = await userStatusPresetCollection(uid)
    .where("cubeFace", "==", orientation)
    .limit(2)
    .get();

  if (snapshot.docs.length !== 1) {
    return null;
  }

  const data = snapshot.docs[0].data();
  const label = truncateStatusText(asTrimmedString(data?.label));
  const emoji = asTrimmedString(data?.slackEmojiCode);

  if (label == null || emoji == null) {
    return null;
  }

  return {emoji, text: label};
}

async function setSlackStatus(
  accessToken: string,
  statusText: string,
  statusEmoji: string,
) {
  const slack = new WebClient(accessToken);

  await slack.users.profile.set({
    profile: {
      status_emoji: statusEmoji,
      status_expiration: 0,
      status_text: statusText,
    },
  });
}

function isDuplicateStatus(
  connection: FirebaseFirestore.DocumentData | undefined,
  status: SlackStatusPayload,
): boolean {
  return connection?.lastStatusText === status.text &&
    connection?.lastStatusEmoji === status.emoji;
}

function isCoolingDown(
  connection: FirebaseFirestore.DocumentData | undefined,
): boolean {
  const lastUpdateAt = connection?.lastSlackUpdateAt;

  if (!(lastUpdateAt instanceof Timestamp)) {
    return false;
  }

  return Date.now() - lastUpdateAt.toMillis() < cooldownMs;
}
