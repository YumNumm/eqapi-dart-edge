// ignore_for_file: unreachable_from_main

import 'dart:convert';
import 'dart:typed_data';

import 'package:api/cf_workers_interop.dart';
import 'package:api/fetch_api_http_client.dart';
import 'package:api/provider/env.dart';
import 'package:api/provider/handler.dart';
import 'package:api/provider/supabase.dart';
import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:web/web.dart' as web;

// MEMO(YumNumm): コンテナを変数に保持。WASMが破棄されるまで使いまわす
late ProviderContainer? _container;
// MEMO(YumNumm): `_container`は`main`関数の初期で初期化されるため
// 後続処理では`null`ではないことが保証される
ProviderContainer get container => _container!;

Future<void> main() async {
  final cfDartWorkers = getFetchContext();
  final request =
      cfDartWorkers
          .request; // 'package:web/web.dart'のRequest

  try {
    final jsEnv = JSEnv(cfDartWorkers.env);
    _container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(jsEnv),
        httpClientProvider.overrideWithValue(
          FetchApiHttpClient(
            // ignore: unnecessary_lambdas
            fetch: (requestInfo, [requestInit]) =>
                cfDartWorkers.fetch(requestInfo, requestInit),
          ),
        ),
      ],
    );

    final handler = container.read(handlerProvider);

    final response = await handler(request.toShelf);

    final bytes = await response.read().fold<List<int>>(
      [],
      (previousValue, element) => [
        ...previousValue,
        ...element,
      ],
    );

    // Content-Typeをチェックしてテキストかバイナリかを判断
    final contentType =
        response.headers['content-type'] ?? '';
    final isTextContent = _isTextContentType(contentType);

    // テキストの場合はString、それ以外はArrayBufferとして渡す
    final jsResponse =
        isTextContent
            ? web.Response(
              utf8.decode(bytes).toJS,
              web.ResponseInit(
                headers: response.headers.toJSDeep,
                status: response.statusCode,
              ),
            )
            : web.Response(
              Uint8List.fromList(bytes).buffer.toJS,
              web.ResponseInit(
                headers: response.headers.toJSDeep,
                status: response.statusCode,
              ),
            );

    cfDartWorkers.response(jsResponse);
    return;
  } on Exception catch (e, st) {
    print(e);
    String mask(String s) =>
        s.replaceAll(RegExp('https?://[^ ]+'), '[MASKED]');
    cfDartWorkers.response(
      web.Response(
        jsonEncode({
          'error': mask(e.toString()),
          'stackTrace': mask(st.toString()),
        }).toJS,
        web.ResponseInit(status: 500),
      ),
    );
    return;
  }
}

extension on web.Request {
  shelf.Request get toShelf {
    final uri = Uri.parse(url);
    return shelf.Request(
      method,
      uri,
      headers: headers.toMap().cast<String, Object>(),
      body: _bodyStream(),
    );
  }

  // See: https://github.com/dart-lang/http/blob/29c5733014d8cc485a6b11b24c5b11ba172cb686/pkgs/http/lib/src/browser_client.dart#L143
  Stream<List<int>> _bodyStream() async* {
    final bodyStreamReader =
        body?.getReader()
            as web.ReadableStreamDefaultReader?;
    if (bodyStreamReader == null) {
      return;
    }

    while (true) {
      final chunk = await bodyStreamReader.read().toDart;
      if (chunk.done) {
        break;
      }
      yield (chunk.value! as JSUint8Array).toDart;
    }
  }
}

// テキストベースのContent-Typeかどうかを判定
bool _isTextContentType(String contentType) {
  final lowerCase = contentType.toLowerCase();
  return lowerCase.contains('text/') ||
      lowerCase.contains('application/json') ||
      lowerCase.contains('application/xml') ||
      lowerCase.contains('application/javascript') ||
      lowerCase.contains('+json') ||
      lowerCase.contains('+xml');
}
