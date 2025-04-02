import 'package:api/provider/env.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';

part 'supabase.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabase(Ref ref) {
  final env = ref.watch(envProvider);

  return SupabaseClient(
    env.supabaseUrl,
    env.supabaseKey,
  );
}
