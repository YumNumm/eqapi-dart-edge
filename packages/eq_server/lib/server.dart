import 'dart:convert';
import 'dart:io';

import 'package:eq_server/src/generated/endpoints.dart';
import 'package:eq_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

// This is the starting point of your Serverpod server.
Future<void> run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Start the server.
  await pod.start();
}

Future<void> handleRequest(HttpRequest request) async {
  await IOOverrides.runWithIOOverrides(() async {
    print('handleRequest');
    final pod = Serverpod([], Protocol(), Endpoints());
    print('pod');

    pod.webServer.handleRequest(request);
  }, JSIOOverrides());
}

class JSIOOverrides extends IOOverrides {
  @override
  Stdin get stdin => throw UnimplementedError();

  @override
  Stdout get stdout => _stdout;

  @override
  Stdout get stderr => _stderr;

  final _stdout = _JSStdout();
  final _stderr = _JSStdout();
}

// 新しいStdoutの実装
class _JSStdout implements Stdout {
  @override
  void write(Object? object) {
    print(object);
  }

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding encoding) {
    // 何もしない
  }

  @override
  IOSink get nonBlocking => this;

  @override
  bool get hasTerminal => false;

  @override
  int get terminalColumns =>
      throw const StdoutException('Terminal not available');

  @override
  int get terminalLines =>
      throw const StdoutException('Terminal not available');

  @override
  bool get supportsAnsiEscapes => false;

  @override
  String get lineTerminator => '\n';

  @override
  set lineTerminator(String lineTerminator) {
    // 何もしない
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    return Future.value();
  }

  @override
  void add(List<int> data) {
    print('add: $data');
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // 何もしない
  }

  @override
  Future<void> close() {
    return Future.value();
  }

  @override
  Future get done => Future.value();

  @override
  Future<void> flush() {
    return Future.value();
  }

  @override
  void writeAll(Iterable objects, [String sep = '']) {
    write(objects.join(sep));
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write('$object\n');
  }
}
