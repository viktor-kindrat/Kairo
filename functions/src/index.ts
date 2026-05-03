import {initializeApp} from "firebase-admin/app";
import {
  disconnectSlack,
  getSlackConnectionStatus,
} from "./slack/connection";
import {
  createSlackOAuthUrl,
  slackOAuthCallback,
} from "./slack/oauth";
import {syncSlackStatusOnMqttEvent} from "./slack/status_sync";
import {
  cleanupUserDataOnDelete,
  seedUserDefaultsOnCreate,
} from "./users/auth_lifecycle";
import {deleteCurrentUserAccount} from "./users/user_data";

initializeApp();

export {
  createSlackOAuthUrl,
  disconnectSlack,
  cleanupUserDataOnDelete,
  getSlackConnectionStatus,
  deleteCurrentUserAccount,
  seedUserDefaultsOnCreate,
  slackOAuthCallback,
  syncSlackStatusOnMqttEvent,
};
