import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static const String supabaseUrl = 'https://puogteiuckjxrlvedatc.supabase.co';

  static const String supabasePublishableKey =
      'sb_publishable_aCAVJTDrRmaprMRaPD4N6g_XkGnaoW6';

  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabasePublishableKey.isNotEmpty &&
        !supabaseUrl.contains('PASTE_') &&
        !supabasePublishableKey.contains('PASTE_');
  }

  static Future<void> initialize() async {
    if (!isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
