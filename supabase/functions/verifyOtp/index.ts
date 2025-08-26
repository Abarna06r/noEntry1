import { serve } from "https://deno.land/x/sift/mod.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL"),
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
);

serve(async (req) => {
  const { email, otp } = await req.json();

  if (!email || !otp) {
    return new Response(JSON.stringify({ verified: false, error: "Email and OTP required" }), { status: 400 });
  }

  const { data } = await supabase
    .from("email_otps")
    .select("*")
    .eq("email", email)
    .eq("otp", otp)
    .limit(1)
    .single();

  if (data) {
    // Delete OTP after successful verification
    await supabase.from("email_otps").delete().eq("id", data.id);
    return new Response(JSON.stringify({ verified: true }));
  } else {
    return new Response(JSON.stringify({ verified: false }));
  }
});
