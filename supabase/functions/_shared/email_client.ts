export class NotConfiguredError extends Error {}

export interface EmailMessage {
  to: string;
  subject: string;
  body: string;
}

/**
 * The one function every caller uses to send mail — swapping the stub
 * below for a real provider call (once RESEND_API_KEY, or an equivalent,
 * exists) means editing this file only. Nothing that calls sendEmail needs
 * to change. Until then this throws rather than silently pretending to
 * have sent something.
 */
export async function sendEmail(_message: EmailMessage): Promise<void> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    throw new NotConfiguredError(
      "No email provider is configured — RESEND_API_KEY (or equivalent) is not set.",
    );
  }

  // Real implementation goes here once a key exists — e.g. POST to
  // https://api.resend.com/emails with { from, to, subject, html }.
  await Promise.resolve();
  throw new NotConfiguredError("Email provider integration not yet implemented.");
}
