import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { initializeApp, cert } from "https://esm.sh/firebase-admin/app";
import { getMessaging } from "https://esm.sh/firebase-admin/messaging";

// Initialize Firebase Admin SDK with environment secrets
const serviceAccount = {
  projectId: Deno.env.get("FIREBASE_PROJECT_ID"),
  privateKey: Deno.env.get("FIREBASE_PRIVATE_KEY")?.replace(/\\n/g, "\n"),
  clientEmail: Deno.env.get("FIREBASE_CLIENT_EMAIL"),
};

console.log("Initializing Firebase with project ID:", serviceAccount.projectId);

const app = initializeApp({ credential: cert(serviceAccount) });

serve(async (req) => {
  try {
    console.log("Function invoked");

    const data = await req.json();
    console.log("Received data:", JSON.stringify(data));

    const { token, title, body, userId } = data;

    if (!token || !title || !body) {
      console.error("Missing required fields");
      return new Response(
        JSON.stringify({ success: false, error: "Missing token, title, or body" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const message = {
      token,
      notification: { title, body },
      data: { userId: userId || "" },
    };

    console.log("Sending FCM message:", JSON.stringify(message));

    const messaging = getMessaging(app);
    const response = await messaging.send(message);

    console.log("FCM send response:", JSON.stringify(response));

    return new Response(
      JSON.stringify({ success: true, fcmResponse: response }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Function error:", String(error));
    return new Response(
      JSON.stringify({ success: false, error: String(error) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
