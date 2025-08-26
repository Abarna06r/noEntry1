import { serve } from "https://deno.land/x/sift/mod.ts";
import * as smtp from "https://deno.land/x/smtp/mod.ts"; 

// Read secrets from Supabase Secrets
const SMTP_HOST = Deno.env.get("SMTP_HOST") || "smtp.gmail.com";
const SMTP_PORT = parseInt(Deno.env.get("SMTP_PORT") || "587");
const SMTP_USER = Deno.env.get("SMTP_USER");
const SMTP_PASS = Deno.env.get("SMTP_PASS");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || SMTP_USER;

// Generate 6-digit OTP
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method Not Allowed" }), { status: 405 });
    }

    const body = await req.json();
    const email = body.email;
    if (!email) {
      return new Response(JSON.stringify({ error: "Email is required" }), { status: 400 });
    }

    const otp = generateOtp();

    // Connect to SMTP
    const client = new smtp.SmtpClient();
    await client.connect({
      hostname: SMTP_HOST,
      port: SMTP_PORT,
      username: SMTP_USER,
      password: SMTP_PASS,
    });

    await client.send({
      from: FROM_EMAIL,
      to: email,
      subject: "Your OTP Code",
      content: `Your OTP code is: ${otp}`,
    });

    await client.close();

    // Response
    return new Response(JSON.stringify({ success: true, message: `OTP sent to ${email}` }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });

  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});
