import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// package:http の Request を dart:io の HttpRequest にラップするアダプター
class CloudflareHttpRequest implements io.HttpRequest {
  CloudflareHttpRequest(this._request)
    : _response = CloudflareHttpResponse(),
      _requestedUri = _request.url;

  final http.Request _request;
  final CloudflareHttpResponse _response;
  final Uri _requestedUri;
  Stream<Uint8List>? _cachedBody;

  @override
  int get contentLength => _request.contentLength;

  @override
  io.HttpHeaders get headers => CloudflareHttpHeaders.fromMap(_request.headers);

  @override
  String get method => _request.method;

  @override
  Uri get uri => _request.url;

  @override
  Uri get requestedUri => _requestedUri;

  @override
  io.HttpResponse get response => _response;

  @override
  io.HttpConnectionInfo? get connectionInfo => null;

  @override
  io.X509Certificate? get certificate => null;

  @override
  List<io.Cookie> get cookies {
    final cookies = <io.Cookie>[];
    final cookieHeader = _request.headers['cookie'];
    if (cookieHeader != null) {
      final cookieParts = cookieHeader.split(';');
      for (final part in cookieParts) {
        final cookiePair = part.trim().split('=');
        if (cookiePair.length == 2) {
          cookies.add(io.Cookie(cookiePair[0], cookiePair[1]));
        }
      }
    }
    return cookies;
  }

  @override
  bool get persistentConnection =>
      _request.headers['connection']?.toLowerCase() != 'close';

  @override
  String get protocolVersion => '1.1'; // HTTP/1.1を想定

  @override
  io.HttpSession get session {
    throw UnsupportedError(
      'Sessions are not supported in Cloudflare Workers environment',
    );
  }

  // Stream methods implementation
  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.any(test);
  }

  @override
  Stream<Uint8List> asBroadcastStream({
    void Function(StreamSubscription<Uint8List> subscription)? onListen,
    void Function(StreamSubscription<Uint8List> subscription)? onCancel,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.asBroadcastStream(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List event) convert) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.cast<R>();
  }

  @override
  Future<bool> contains(Object? needle) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.contains(needle);
  }

  @override
  Stream<Uint8List> distinct([
    bool Function(Uint8List previous, Uint8List next)? equals,
  ]) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.drain(futureValue);
  }

  @override
  Future<Uint8List> elementAt(int index) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.expand(convert);
  }

  @override
  Future<Uint8List> get first {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.first;
  }

  @override
  Future<Uint8List> firstWhere(
    bool Function(Uint8List element) test, {
    Uint8List Function()? orElse,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(
    S initialValue,
    S Function(S previous, Uint8List element) combine,
  ) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(Uint8List element) action) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.forEach(action);
  }

  @override
  Stream<Uint8List> handleError(
    Function onError, {
    bool Function(dynamic error)? test,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.isBroadcast;
  }

  @override
  Future<bool> get isEmpty {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.isEmpty;
  }

  @override
  Future<String> join([String separator = '']) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.join(separator);
  }

  @override
  Future<Uint8List> get last {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.last;
  }

  @override
  Future<Uint8List> lastWhere(
    bool Function(Uint8List element) test, {
    Uint8List Function()? orElse,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.length;
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.map(convert);
  }

  @override
  Future<dynamic> pipe(StreamConsumer<Uint8List> streamConsumer) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.pipe(streamConsumer);
  }

  @override
  Future<Uint8List> reduce(
    Uint8List Function(Uint8List previous, Uint8List element) combine,
  ) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.reduce(combine);
  }

  @override
  Future<Uint8List> get single {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.single;
  }

  @override
  Future<Uint8List> singleWhere(
    bool Function(Uint8List element) test, {
    Uint8List Function()? orElse,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.singleWhere(test, orElse: orElse);
  }

  @override
  Stream<Uint8List> skip(int count) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.skip(count);
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.skipWhile(test);
  }

  @override
  Stream<Uint8List> take(int count) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.take(count);
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.takeWhile(test);
  }

  @override
  Stream<Uint8List> timeout(
    Duration timeLimit, {
    void Function(EventSink<Uint8List> sink)? onTimeout,
  }) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<Uint8List>> toList() {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.toList();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Uint8List, S> streamTransformer) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.transform(streamTransformer);
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    _cachedBody ??= _createBodyStream();
    return _cachedBody!.where(test);
  }

  Stream<Uint8List> _createBodyStream() {
    // リクエストボディをUint8Listのストリームに変換
    final bodyBytes = Uint8List.fromList(_request.bodyBytes);
    return Stream.value(bodyBytes);
  }
}

/// dart:io の HttpResponse をシミュレートするクラス
class CloudflareHttpResponse implements io.HttpResponse {
  final _controller = StreamController<List<int>>();
  final _buffer = <int>[];
  final CloudflareHttpHeaders _headers = CloudflareHttpHeaders();
  bool _isClosed = false;
  Encoding _encoding = utf8;
  final Completer<void> _doneCompleter = Completer<void>();

  @override
  int statusCode = 200;

  @override
  String reasonPhrase = 'OK';

  @override
  io.HttpHeaders get headers => _headers;

  @override
  Encoding get encoding => _encoding;

  @override
  set encoding(Encoding value) {
    _encoding = value;
  }

  @override
  int contentLength = -1;

  @override
  bool bufferOutput = true;

  @override
  bool persistentConnection = true;

  @override
  io.HttpConnectionInfo? get connectionInfo => null;

  @override
  List<io.Cookie> get cookies => <io.Cookie>[];

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  void add(List<int> data) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    _buffer.addAll(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    _controller.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    final completer = Completer<void>();
    stream.listen(
      _buffer.addAll,
      onError: completer.completeError,
      onDone: completer.complete,
      cancelOnError: true,
    );
    return completer.future;
  }

  @override
  void write(Object? object) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    if (object == null) {
      return;
    }
    add(_encoding.encode(object.toString()));
  }

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    if (_isClosed) {
      throw StateError('Response has been closed');
    }
    write('$object\n');
  }

  @override
  Future<void> close() {
    if (_isClosed) {
      return Future<void>.value();
    }
    _isClosed = true;
    _controller.add(_buffer);
    _controller.close();
    _doneCompleter.complete();
    return Future<void>.value();
  }

  @override
  Future<io.Socket> detachSocket({bool writeHeaders = true}) {
    throw UnsupportedError(
      'Socket detachment is not supported in Cloudflare Workers environment',
    );
  }

  @override
  Future<void> flush() {
    return Future<void>.value();
  }

  @override
  Future<void> redirect(Uri location, {int status = 302}) {
    statusCode = status;
    headers.set(io.HttpHeaders.locationHeader, location.toString());
    return close();
  }

  @override
  Duration? deadline;

  /// HTTP Response に変換するメソッド
  http.Response toHttpResponse() {
    return http.Response(
      utf8.decode(_buffer),
      statusCode,
      headers: _headers._headers,
      reasonPhrase: reasonPhrase,
    );
  }
}

/// dart:io の HttpHeaders をシミュレートするクラス
class CloudflareHttpHeaders implements io.HttpHeaders {
  CloudflareHttpHeaders();

  factory CloudflareHttpHeaders.fromMap(Map<String, String> headers) {
    final result = CloudflareHttpHeaders();
    headers.forEach((key, value) {
      result._headers[key.toLowerCase()] = value;
      result._multiHeaders[key.toLowerCase()] = [value];
    });
    return result;
  }

  final Map<String, String> _headers = {};
  final Map<String, List<String>> _multiHeaders = {};
  final Set<String> _noFoldingHeaders = {'set-cookie'};

  @override
  List<String>? operator [](String name) {
    final normalizedName = name.toLowerCase();
    return _multiHeaders[normalizedName];
  }

  @override
  String? value(String name) {
    final normalizedName = name.toLowerCase();
    return _headers[normalizedName];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final headerName = preserveHeaderCase ? name : name.toLowerCase();
    final stringValue = value.toString();

    _headers[headerName] = stringValue;

    if (_multiHeaders.containsKey(headerName)) {
      _multiHeaders[headerName]!.add(stringValue);
    } else {
      _multiHeaders[headerName] = [stringValue];
    }
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    final headerName = preserveHeaderCase ? name : name.toLowerCase();
    final stringValue = value.toString();

    _headers[headerName] = stringValue;
    _multiHeaders[headerName] = [stringValue];
  }

  @override
  void remove(String name, Object value) {
    final normalizedName = name.toLowerCase();
    final stringValue = value.toString();

    if (_multiHeaders.containsKey(normalizedName)) {
      _multiHeaders[normalizedName]!.remove(stringValue);
      if (_multiHeaders[normalizedName]!.isEmpty) {
        _multiHeaders.remove(normalizedName);
        _headers.remove(normalizedName);
      } else {
        _headers[normalizedName] = _multiHeaders[normalizedName]!.first;
      }
    }
  }

  @override
  void removeAll(String name) {
    final normalizedName = name.toLowerCase();
    _headers.remove(normalizedName);
    _multiHeaders.remove(normalizedName);
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _multiHeaders.forEach(action);
  }

  @override
  void noFolding(String name) {
    _noFoldingHeaders.add(name.toLowerCase());
  }

  @override
  void clear() {
    _headers.clear();
    _multiHeaders.clear();
  }

  // HttpHeadersの属性の実装
  @override
  DateTime? date;

  @override
  DateTime? expires;

  @override
  DateTime? ifModifiedSince;

  @override
  String? host;

  @override
  int? port;

  @override
  io.ContentType? get contentType {
    final value = this.value(io.HttpHeaders.contentTypeHeader);
    if (value == null) {
      return null;
    }
    try {
      return io.ContentType.parse(value);
    } on FormatException {
      return null;
    }
  }

  @override
  set contentType(io.ContentType? value) {
    if (value == null) {
      removeAll(io.HttpHeaders.contentTypeHeader);
    } else {
      set(io.HttpHeaders.contentTypeHeader, value.toString());
    }
  }

  @override
  int get contentLength {
    final value = this.value(io.HttpHeaders.contentLengthHeader);
    if (value != null) {
      try {
        return int.parse(value);
      } on FormatException {
        return -1;
      }
    }
    return -1;
  }

  @override
  set contentLength(int length) {
    if (length >= 0) {
      set(io.HttpHeaders.contentLengthHeader, length.toString());
    } else {
      removeAll(io.HttpHeaders.contentLengthHeader);
    }
  }

  @override
  bool get persistentConnection {
    final connection = value(io.HttpHeaders.connectionHeader)?.toLowerCase();
    return connection != 'close';
  }

  @override
  set persistentConnection(bool persistentConnection) {
    if (persistentConnection) {
      set(io.HttpHeaders.connectionHeader, 'keep-alive');
    } else {
      set(io.HttpHeaders.connectionHeader, 'close');
    }
  }

  @override
  bool get chunkedTransferEncoding {
    final transferEncoding =
        value(io.HttpHeaders.transferEncodingHeader)?.toLowerCase();
    return transferEncoding == 'chunked';
  }

  @override
  set chunkedTransferEncoding(bool chunkedTransferEncoding) {
    if (chunkedTransferEncoding) {
      set(io.HttpHeaders.transferEncodingHeader, 'chunked');
    } else {
      removeAll(io.HttpHeaders.transferEncodingHeader);
    }
  }
}
