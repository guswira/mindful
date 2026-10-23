// Forwards the app's Gemini requests to Google with the API key kept here,
// so it never ships in the app (on web `.env` is a public file).
//
// The app's GeminiProxyClient (lib/shared/services/gemini_proxy_client.dart)
// sends the SDK's own request unchanged to
//   /functions/v1/gemini-proxy/v1beta/models/<model>:generateContent
// with the user's Supabase JWT. Supabase verifies that JWT before this runs
// (verify_jwt, on by default), so only signed-in users can spend the quota.
//
// Deploy:
//   supabase secrets set GEMINI_API_KEY=...
//   supabase functions deploy gemini-proxy

const GEMINI_BASE = "https://generativelanguage.googleapis.com";

// Only generateContent on the models the app uses — this is not a general
// Gemini passthrough.
const ALLOWED_PATH = /^\/v1(beta)?\/models\/gemini-[\w.-]+:generateContent$/;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-goog-api-client, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json(405, "Method not allowed");
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) {
    return json(500, "GEMINI_API_KEY is not set on the function");
  }

  const url = new URL(req.url);
  const path = url.pathname.replace(/^.*?\/gemini-proxy/, "");
  if (!ALLOWED_PATH.test(path)) {
    return json(404, "NOT_FOUND: unsupported Gemini path");
  }

  const upstream = await fetch(`${GEMINI_BASE}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    },
    body: await req.arrayBuffer(),
  });

  // Status and body as Google sent them, so the app's SDK parses Gemini's
  // errors (UNAVAILABLE, RESOURCE_EXHAUSTED, ...) exactly as before.
  return new Response(upstream.body, {
    status: upstream.status,
    headers: {
      ...corsHeaders,
      "Content-Type":
        upstream.headers.get("Content-Type") ?? "application/json",
    },
  });
});

/// An error in Google's own shape, which the Gemini SDK knows how to read.
function json(status: number, message: string): Response {
  return new Response(
    JSON.stringify({ error: { code: status, message, status: "PROXY_ERROR" } }),
    {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
}
