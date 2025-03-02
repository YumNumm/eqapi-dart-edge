import 'dart:convert';
import 'dart:js_interop';

import 'package:api/src/util/fetch_http_client.dart';
import 'package:cf_workers/cf_workers.dart';
import 'package:cf_workers/http.dart';
import 'package:http/http.dart';
import 'package:supabase/supabase.dart';

Future<void> main() async =>
    Workers((request, env, ctx) async {
      final _ = await request.toDart;
      final jsEnv = JSEnv(env);
      final supabase = SupabaseClient(
        jsEnv.supabaseUrl,
        jsEnv.supabaseKey,
        httpClient: FetchHttpClient(),
      );

      final result = await supabase
          .from('earthquake')
          .select('event_id, headline, origin_time')
          .limit(1)
          .order('origin_time', ascending: false);
      return Response.bytes(
        utf8.encode(jsonEncode(result)),
        200,
        
      ).toJS;
    }).serve();

extension type JSEnv(JSObject _) implements JSObject {
  @JS('SUPABASE_URL')
  external String get supabaseUrl;

  @JS('SUPABASE_KEY')
  external String get supabaseKey;
}
