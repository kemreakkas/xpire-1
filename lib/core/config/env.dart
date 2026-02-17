/// Build-time environment. Set via Vercel (or CLI):
///   --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// Do NOT hardcode these values.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
