import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  const SupabaseService._();

  static bool _isInitialized = false;

  static bool get isConfigured => SupabaseConfig.isConfigured;

  static bool get isInitialized => _isInitialized;

  static SupabaseClient? get client {
    if (!_isInitialized) {
      return null;
    }

    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint(
        'Supabase is not configured yet. App will continue in local demo mode.',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabasePublishableKey,
      );

      _isInitialized = true;

      debugPrint('Supabase initialized successfully.');
    } catch (error, stackTrace) {
      _isInitialized = false;

      debugPrint('Supabase initialization failed.');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    }
  }
}
