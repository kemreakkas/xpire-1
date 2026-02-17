import 'env.dart';

/// Supabase configuration. Uses [env] (--dart-define from Vercel or CLI).
class SupabaseConfig {
  SupabaseConfig._();

  static String get url => supabaseUrl;
  static String get anonKey => supabaseAnonKey;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
