import {getFirestore} from "firebase-admin/firestore";

export const privateConnectionCollection = "slack_connections_private";
export const oauthStateCollection = "slack_oauth_states";

export function slackConnectionDocument(uid: string) {
  return getFirestore().collection(privateConnectionCollection).doc(uid);
}

export function slackOAuthStateDocument(state: string) {
  return getFirestore().collection(oauthStateCollection).doc(state);
}

export function userStatusPresetCollection(uid: string) {
  return getFirestore()
    .collection("users")
    .doc(uid)
    .collection("status_presets");
}
