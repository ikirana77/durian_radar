class SupabaseConfig {
  const SupabaseConfig._();

  static const String placeholderUrl = 'https://your-project-ref.supabase.co';
  static const String placeholderPublishableKey =
      'your-supabase-publishable-key';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: placeholderUrl,
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: placeholderPublishableKey,
  );

  static bool get isConfigured {
    final hasRealUrl =
        supabaseUrl.trim().startsWith('https://') &&
        supabaseUrl.trim() != placeholderUrl;

    final hasRealPublishableKey =
        supabasePublishableKey.trim().isNotEmpty &&
        supabasePublishableKey.trim() != placeholderPublishableKey;

    return hasRealUrl && hasRealPublishableKey;
  }
}
