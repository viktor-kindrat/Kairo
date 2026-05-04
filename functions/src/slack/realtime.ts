import {getDatabase, ServerValue} from "firebase-admin/database";

export function slackIntegrationReference(uid: string) {
  return getDatabase().ref(`users/${uid}/integrations/slack`);
}

export async function setSlackIntegrationConnected(
  uid: string,
  connected: boolean,
) {
  await slackIntegrationReference(uid).update({
    connected,
    updatedAt: ServerValue.TIMESTAMP,
  });
}
