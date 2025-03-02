// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earthquake.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$EarthquakeServiceRouter(EarthquakeService service) {
  final router = Router();
  router.add('GET', r'/earthquake/list', service.list);
  router.add('GET', r'/earthquake/id/<id>', service.get);
  return router;
}
