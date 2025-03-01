import 'dart:js_interop';

import 'package:cf_workers/cf_workers.dart';
import 'package:cf_workers/http.dart';
import 'package:http/http.dart';

@JS('fetch')
external JSPromise<JSResponse> fetch(JSString input);

Future<void> main() async =>
    Workers((request, env, ctx) async {
      final response =
          await fetch(
            'https://jsonplaceholder.typicode.com/todos/1'.toJS,
          ).toDart;
      print((await response.toDart).body);

      final environment = JSEnv(env);
      print(environment.supabaseKey);

      return Response('OK', 200).toJS;
    }).serve();

extension type JSEnv(JSObject _) implements JSObject {
  @JS('SUPABASE_URL')
  external String get supabaseUrl;

  @JS('SUPABASE_KEY')
  external String get supabaseKey;
}
