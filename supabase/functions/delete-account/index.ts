import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!url || !anonKey || !serviceKey) return json({ error: "Server misconfigured" }, 500);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);

  // Confere quem está pedindo a exclusão pelo token da sessão.
  const userClient = createClient(url, anonKey, { global: { headers: { Authorization: auth } } });
  const { data, error: userErr } = await userClient.auth.getUser(auth.slice(7));
  if (userErr || !data.user) return json({ error: userErr?.message ?? "Invalid session" }, 401);
  const uid = data.user.id;

  const admin = createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const mood = await admin.from("pulse_wellbeing_logs").delete().eq("user_id", uid);
  if (mood.error) return json({ error: mood.error.message }, 500);

  const habits = await admin.from("pulse_habits").select("id").eq("user_id", uid);
  if (habits.error) return json({ error: habits.error.message }, 500);

  const ids = (habits.data ?? []).map((h: { id: string }) => h.id);
  if (ids.length > 0) {
    const done = await admin.from("pulse_habit_completions").delete().in("habit_id", ids);
    if (done.error) return json({ error: done.error.message }, 500);
  }

  const delHabits = await admin.from("pulse_habits").delete().eq("user_id", uid);
  if (delHabits.error) return json({ error: delHabits.error.message }, 500);

  // Apagar o usuário remove em cascata XP, conquistas e perfil.
  const delUser = await admin.auth.admin.deleteUser(uid);
  if (delUser.error) return json({ error: delUser.error.message }, 500);

  return json({ ok: true });
});
