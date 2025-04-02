import 'package:api/service/earthquake.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'api_service.g.dart';

@Riverpod(
  keepAlive: true,
  dependencies: [earthquakeService],
)
ApiService apiService(Ref ref) => ApiService(
  earthquakeService: ref.watch(earthquakeServiceProvider),
);

class ApiService {
  ApiService({required EarthquakeService earthquakeService})
    : _earthquakeService = earthquakeService;

  final EarthquakeService _earthquakeService;

  @Route.get('/')
  Future<Response> _getIndex(Request request) async {
    final stringBuffer = StringBuffer();
    stringBuffer.writeln('''
      <h1>Earthquake API</h1>
      <ul>
        <li><a href="/earthquake/list">/earthquake/list</a></li>
      </ul>
    ''');
    return Response.ok(stringBuffer.toString());
  }

  @Route.get('/hello')
  Future<Response> _getHello(Request request) async {
    return Response.ok('Hello, World!');
  }

  @Route.mount('/earthquake')
  Router get _earthquakeApi => _earthquakeService.router;

  Router get router => _$ApiServiceRouter(this);
}
