import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String resolveBackendBaseUrl() {
  const env = String.fromEnvironment('BACKEND_BASE_URL', defaultValue: '');
  if (env.isNotEmpty) return env;
  if (kIsWeb) return 'http://localhost:3000';

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3000';
    default:
      return 'http://localhost:3000';
  }
}

final backendBaseUrlProvider = Provider<String>((ref) {
  return resolveBackendBaseUrl();
});
