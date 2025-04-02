import 'dart:convert';
import 'dart:io';

import 'package:api/main.dart';
import 'package:api/provider/supabase.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'earthquake.g.dart';

@Riverpod(keepAlive: true)
EarthquakeService earthquakeService(Ref ref) =>
    EarthquakeService();

class EarthquakeService {
  @Route.get('/list')
  Future<Response> list(Request request) async {
    final supabase = container.read(supabaseProvider);

    final limit =
        int.tryParse(
          request.url.queryParameters['limit'].toString(),
        ) ??
        10;
    if (limit < 1 || limit > 100) {
      return Response.badRequest(
        body: 'limit must be between 1 and 100',
      );
    }
    final list = await supabase
        .from('earthquake')
        .select()
        .order('event_id', ascending: false)
        .limit(limit);
    print(list);
    return Response.ok(
      jsonEncode(list),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
  }

  Router get router => _$EarthquakeServiceRouter(this);
}
