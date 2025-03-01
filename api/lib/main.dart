import 'dart:js_interop';

import 'package:api/src/adapter/http_adapter.dart';
import 'package:cf_workers/cf_workers.dart';
import 'package:cf_workers/http.dart';
import 'package:eq_server/server.dart';

@JS('fetch')
external JSPromise<JSResponse> fetch(JSString input);

Future<void> main() async =>
    Workers((request, env, ctx) async {
      final httpRequest = await request.toDart;

      // http.Request を CloudflareHttpRequest にラップ
      final cfRequest = CloudflareHttpRequest(httpRequest);

      // handleRequest を呼び出す
      await handleRequest(cfRequest);

      // レスポンスを取得して返す
      final cfResponse = cfRequest.response as CloudflareHttpResponse;
      return cfResponse.toHttpResponse().toJS;
    }).serve();

extension type JSEnv(JSObject _) implements JSObject {
  @JS('SUPABASE_URL')
  external String get supabaseUrl;

  @JS('SUPABASE_KEY')
  external String get supabaseKey;
}
