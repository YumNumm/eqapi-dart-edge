import 'dart:js_interop';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'env.g.dart';

@Riverpod(keepAlive: true)
JSEnv env(Ref ref) =>
    throw UnimplementedError(
      'please inject from ProviderContainer.',
    );

extension type JSEnv(JSObject _) implements JSObject {
  @JS('SUPABASE_URL')
  external String get supabaseUrl;

  @JS('SUPABASE_KEY')
  external String get supabaseKey;
}
