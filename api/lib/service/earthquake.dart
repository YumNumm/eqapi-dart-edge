import 'dart:convert';
import 'dart:io';

import 'package:api/main.dart';
import 'package:api/provider/supabase.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'earthquake.g.dart';

class EarthquakeService {
  @Route.get('/earthquake/list')
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
    return Response.ok(
      jsonEncode(list),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
  }

  @Route.get('/earthquake/id/<id>')
  Future<Response> get(Request request, String id) async {
    final supabase = container.read(supabaseProvider);
    final data = await supabase
        .from('earthquake')
        .select()
        .eq('id', id);
    return Response.ok(data);
  }

  Router get router => _$EarthquakeServiceRouter(this);
}
