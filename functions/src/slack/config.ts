import {defineSecret} from "firebase-functions/params";

export const slackClientId = defineSecret("SLACK_CLIENT_ID");
export const slackClientSecret = defineSecret("SLACK_CLIENT_SECRET");
export const slackRedirectUri = defineSecret("SLACK_REDIRECT_URI");

export const slackSecrets = [
  slackClientId,
  slackClientSecret,
  slackRedirectUri,
];
