export class NotConfiguredError extends Error {}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function base64UrlEncode(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/**
 * Signs a short-lived JWT with the service account's own private key and
 * exchanges it for a Google OAuth2 access token scoped to FCM -- the
 * standard way a server sends via the FCM HTTP v1 API. Uses Deno's
 * built-in Web Crypto rather than pulling in a JWT library.
 */
async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const claims = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encoder = new TextEncoder();
  const encode = (obj: unknown) => base64UrlEncode(encoder.encode(JSON.stringify(obj)));
  const unsigned = `${encode(header)}.${encode(claims)}`;

  const keyBody = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binaryKey = Uint8Array.from(atob(keyBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    encoder.encode(unsigned),
  );
  const jwt = `${unsigned}.${base64UrlEncode(new Uint8Array(signature))}`;

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!tokenResponse.ok) {
    throw new Error(`Failed to obtain FCM access token: ${await tokenResponse.text()}`);
  }
  const { access_token } = await tokenResponse.json();
  return access_token as string;
}

/**
 * The one function every caller uses to send a push — swapping in a real
 * FIREBASE_SERVICE_ACCOUNT_JSON secret is all that's needed to go live;
 * nothing that calls this needs to change. Until then it throws rather
 * than pretending to have delivered anything.
 */
export async function sendPush({
  deviceToken,
  title,
  body,
}: {
  deviceToken: string;
  title: string;
  body: string;
}): Promise<void> {
  const saJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (!saJson) {
    throw new NotConfiguredError(
      "FIREBASE_SERVICE_ACCOUNT_JSON is not set — push notifications aren't connected yet.",
    );
  }

  const sa: ServiceAccount = JSON.parse(saJson);
  const accessToken = await getAccessToken(sa);

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: { token: deviceToken, notification: { title, body } },
      }),
    },
  );
  if (!response.ok) {
    throw new Error(`FCM send failed: ${await response.text()}`);
  }
}
