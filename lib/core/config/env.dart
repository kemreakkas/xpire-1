/// Build-time environment. Set via Vercel (or CLI):
///   --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// SUPABASE_ANON_KEY = Supabase Dashboard "Publishable" / anon public key.
/// Do NOT hardcode these values.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
