import 'dart:async';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:cf_workers/http.dart';
import 'package:http/http.dart';
import 'package:js_interop_utils/js_interop_utils.dart';

/// Fetch APIを使ったHTTPクライアント実装
/// Cloudflare Workersなどのエッジ環境で動作します
class FetchHttpClient extends BaseClient {
  /// 新しいFetchHttpClientを作成
  FetchHttpClient({this.timeout});

  /// タイムアウト時間（オプション）
  final Duration? timeout;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    // リクエストをJSのfetch APIで送信
    try {
      // リクエストURLを準備
      final url = request.url.toString().toJS;
      final Uint8List? body;
      if (request is Request &&
          request.bodyBytes.isNotEmpty) {
        body = request.bodyBytes;
      } else {
        final bytes = await request.finalize().toBytes();
        body = bytes.isNotEmpty ? bytes : null;
      }
      final init = RequestInit(
        method: request.method,
        headers: request.headers,
        body: body,
        redirect:
            request.followRedirects ? 'follow' : 'error',
      );

      final response = await fetch(url, init.toJS).toDart;
      final dartResponse = await response.toDart;
      print(dartResponse.headers);

      return StreamedResponse(
        ByteStream.fromBytes(dartResponse.bodyBytes),
        dartResponse.statusCode,
        request: request,
        isRedirect: dartResponse.isRedirect,
        reasonPhrase: dartResponse.reasonPhrase,
        persistentConnection:
            dartResponse.persistentConnection,
        headers: dartResponse.headers,
        contentLength: dartResponse.contentLength,
      );
    } catch (e) {
      print(e.runtimeType);
      throw ClientException(
        'FetchHttpClient error: $e',
        request.url,
      );
    }
  }
}

@override
void close() {
  // 特にクローズする必要のあるリソースはありません
}

extension type JSRequestInit(JSObject _)
    implements JSObject {}

extension JSRequestInitToRequestInit on JSRequestInit {
  RequestInit get toDart {
    final init = RequestInit(
      method: getProperty<JSString>('method'.toJS).toDart,
      headers:
          getProperty<JSObject>('headers'.toJS).dartify()
              as Map<String, String>?,
      body: getProperty<JSString>('body'.toJS).toDart,
      redirect:
          getProperty<JSString>('redirect'.toJS).toDart,
    );
    return init;
  }
}

class RequestInit {
  RequestInit({
    required this.method,
    required this.headers,
    required this.body,
    required this.redirect,
  });

  /// A string to set request's method.
  final String? method;

  /// A string to set request's headers.
  final Map<String, String>? headers;

  /// `String` or `Uint8List`
  final dynamic body;

  /// A string indicating whether request follows redirects, results in an error upon encountering a redirect, or returns the redirect (in an opaque fashion). Sets request's redirect.
  final String? redirect;

  JSRequestInit get toJS {
    final object =
        JSObject()
          ..setProperty('method'.toJS, method?.toJS)
          ..setProperty('headers'.toJS, headers?.toJSDeep)
          ..setProperty(
            'body'.toJS,
            body is String
                ? (body as String).toJS
                : body is Uint8List
                ? (body as Uint8List).toJS
                : null,
          )
          ..setProperty('redirect'.toJS, redirect?.toJS);
    return JSRequestInit(object);
  }
}

class AttributionReporting {
  AttributionReporting({
    required this.eventSourceEligible,
    required this.navigationEligible,
  });

  final bool eventSourceEligible;
  final bool navigationEligible;
}

@JS('fetch')
external JSPromise<JSResponse> fetch(
  JSString url,
  JSRequestInit? init,
);
