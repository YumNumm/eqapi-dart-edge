// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earthquake.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$earthquakeServiceHash() => r'a4e685f51dc742f6fdb7002d45207bfe453b611a';

/// See also [earthquakeService].
@ProviderFor(earthquakeService)
final earthquakeServiceProvider = Provider<EarthquakeService>.internal(
  earthquakeService,
  name: r'earthquakeServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$earthquakeServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EarthquakeServiceRef = ProviderRef<EarthquakeService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$EarthquakeServiceRouter(EarthquakeService service) {
  final router = Router();
  router.add('GET', r'/list', service.list);
  return router;
}
