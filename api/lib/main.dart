// ignore_for_file: unreachable_from_main

import 'package:api/provider/env.dart';
import 'package:api/provider/handler.dart';
import 'package:cf_workers/cf_workers.dart';
import 'package:cf_workers/http.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart' as shelf;

ProviderContainer get container => _container!;
ProviderContainer? _container;

Future<void> main() async =>
    Workers((request, env, ctx) async {
      try {
        final _ = await request.toDart;
        final jsEnv = JSEnv(env);
        _container ??= ProviderContainer(
          overrides: [envProvider.overrideWithValue(jsEnv)],
        );

        final handler = container.read(handlerProvider);

        final response = await handler(
          convertHttpToShelfRequest(await request.toDart),
        );

        final httpResponse =
            await convertShelfToHttpResponse(response);
        return httpResponse.toJS;
      } on Exception catch (e, st) {
        print(e);
        final shelfResponse =
            await convertShelfToHttpResponse(
              shelf.Response.internalServerError(
                body: e.toString(),
                headers: {'context': st.toString()},
              ),
            );
        return shelfResponse.toJS;
      }
    }).serve();

shelf.Request convertHttpToShelfRequest(
  http.Request request,
) {
  return shelf.Request(
    request.method,
    request.url,
    body: request.body,
    headers: request.headers,
  );
}

Future<http.Response> convertShelfToHttpResponse(
  shelf.Response response,
) async {
  final stream = response.read();
  final bytes = await stream.fold<List<int>>(
    <int>[],
    (previous, element) => previous..addAll(element),
  );

  return http.Response.bytes(
    bytes,
    response.statusCode,
    headers: response.headers,
  );
}
