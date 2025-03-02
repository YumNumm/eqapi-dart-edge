import 'package:api/service/earthquake.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';

part 'handler.g.dart';

@Riverpod(keepAlive: true)
Handler handler(Ref ref) {
  final service = EarthquakeService();
  final router = service.router;

  return const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);
}
