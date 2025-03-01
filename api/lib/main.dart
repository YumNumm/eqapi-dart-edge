import 'dart:js_interop';

import 'package:cf_workers/cf_workers.dart';
import 'package:cf_workers/http.dart';
import 'package:http/http.dart';

@JS('fetch')
external JSPromise<JSResponse> fetch(JSString input);

void main() =>
    Workers((request) async {
      final response =
          await fetch(
            'https://jsonplaceholder.typicode.com/todos/1'.toJS,
          ).toDart;
      print((await response.toDart).body);

      return Response('OK', 200).toJS;
    }).serve();
