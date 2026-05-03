import {randomBytes} from "node:crypto";
import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {HttpsError, onCall, onRequest} from "firebase-functions/v2/https";
import {WebClient} from "@slack/web-api";
import {
  slackClientId,
  slackClientSecret,
  slackRedirectUri,
  slackSecrets,
} from "./config";
import {
  slackConnectionDocument,
  slackOAuthStateDocument,
} from "./firestore";
import {setSlackIntegrationConnected} from "./realtime";

const oauthStateTtlMs = 10 * 60 * 1000;
const userScope = "users.profile:write";

export const createSlackOAuthUrl = onCall(
  {secrets: slackSecrets},
  async (request) => {
    const uid = request.auth?.uid;

    if (uid == null) {
      throw new HttpsError("unauthenticated", "Please sign in first.");
    }

    const state = randomBytes(24).toString("hex");
    const expiresAt = Timestamp.fromMillis(Date.now() + oauthStateTtlMs);

    await slackOAuthStateDocument(state).set({
      createdAt: FieldValue.serverTimestamp(),
      expiresAt,
      uid,
    });

    const url = new URL("https://slack.com/oauth/v2/authorize");
    url.searchParams.set("client_id", slackClientId.value());
    url.searchParams.set("redirect_uri", slackRedirectUri.value());
    url.searchParams.set("state", state);
    url.searchParams.set("user_scope", userScope);

    return {url: url.toString()};
  },
);

export const slackOAuthCallback = onRequest(
  {secrets: slackSecrets},
  async (request, response) => {
    const code = asQueryString(request.query.code);
    const state = asQueryString(request.query.state);

    if (code == null || state == null) {
      response.status(400).send("Missing Slack OAuth code or state.");
      return;
    }

    const stateDocument = slackOAuthStateDocument(state);
    const snapshot = await stateDocument.get();
    const stateData = snapshot.data();

    if (stateData == null || isExpired(stateData.expiresAt)) {
      await stateDocument.delete().catch(() => undefined);
      response.status(400).send("Slack OAuth state is invalid or expired.");
      return;
    }

    const uid = typeof stateData.uid === "string" ? stateData.uid : null;

    if (uid == null) {
      await stateDocument.delete().catch(() => undefined);
      response.status(400).send("Slack OAuth state is invalid.");
      return;
    }

    try {
      await persistSlackConnection(uid, code);
      await stateDocument.delete();
      response.status(200).send(successPageHtml());
    } catch (error) {
      logger.error("Slack OAuth callback failed", error);
      response.status(500).send("Slack connection failed. Please try again.");
    }
  },
);

async function persistSlackConnection(uid: string, code: string) {
  const slack = new WebClient();
  const result = await slack.oauth.v2.access({
    client_id: slackClientId.value(),
    client_secret: slackClientSecret.value(),
    code,
    redirect_uri: slackRedirectUri.value(),
  });
  const accessToken = result.authed_user?.access_token;

  if (accessToken == null || result.authed_user?.id == null) {
    throw new Error("Slack OAuth did not return a user token.");
  }

  await slackConnectionDocument(uid).set({
    accessToken,
    connectedAt: FieldValue.serverTimestamp(),
    lastError: FieldValue.delete(),
    lastSlackUpdateAt: FieldValue.delete(),
    lastStatusEmoji: FieldValue.delete(),
    lastStatusText: FieldValue.delete(),
    scope: result.authed_user.scope ?? userScope,
    slackUserId: result.authed_user.id,
    teamId: result.team?.id ?? null,
    teamName: result.team?.name ?? null,
  }, {merge: true});
  await setSlackIntegrationConnected(uid, true);
}

function asQueryString(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function isExpired(value: unknown): boolean {
  return !(value instanceof Timestamp) || value.toMillis() < Date.now();
}

function successPageHtml(): string {
  return "<h1>Slack connected</h1><p>You can return to Kairo now.</p>";
}
