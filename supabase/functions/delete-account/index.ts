import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!supabaseUrl || !serviceRoleKey) {
    return new Response(
      JSON.stringify({ error: "Server misconfigured" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const jwt = authHeader.substring(7);
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userErr } = await userClient.auth.getUser(
    jwt,
  );
  if (userErr || !userData.user) {
    return new Response(
      JSON.stringify({ error: userErr?.message ?? "Invalid session" }),
      {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const uid = userData.user.id;

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { error: wErr } = await admin
    .from("pulse_wellbeing_logs")
    .delete()
    .eq("user_id", uid);
  if (wErr) {
    console.error("pulse_wellbeing_logs delete:", wErr);
    return new Response(
      JSON.stringify({ error: wErr.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const { data: habitRows, error: hSelErr } = await admin
    .from("pulse_habits")
    .select("id")
    .eq("user_id", uid);

  if (hSelErr) {
    console.error("pulse_habits select:", hSelErr);
    return new Response(
      JSON.stringify({ error: hSelErr.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const habitIds = (habitRows ?? []).map((r: { id: string }) => r.id);
  if (habitIds.length > 0) {
    const { error: cErr } = await admin
      .from("pulse_habit_completions")
      .delete()
      .in("habit_id", habitIds);
    if (cErr) {
      console.error("pulse_habit_completions delete:", cErr);
      return new Response(
        JSON.stringify({ error: cErr.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
  }

  const { error: hDelErr } = await admin
    .from("pulse_habits")
    .delete()
    .eq("user_id", uid);
  if (hDelErr) {
    console.error("pulse_habits delete:", hDelErr);
    return new Response(
      JSON.stringify({ error: hDelErr.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const { error: delUserErr } = await admin.auth.admin.deleteUser(uid);
  if (delUserErr) {
    console.error("auth.admin.deleteUser:", delUserErr);
    return new Response(
      JSON.stringify({ error: delUserErr.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
