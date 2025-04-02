// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiServiceHash() => r'c7e9158e9c62b6e50c7c078afb32e42cd5dbd6be';

/// See also [apiService].
@ProviderFor(apiService)
final apiServiceProvider = Provider<ApiService>.internal(
  apiService,
  name: r'apiServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiServiceHash,
  dependencies: <ProviderOrFamily>[earthquakeServiceProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    earthquakeServiceProvider,
    ...?earthquakeServiceProvider.allTransitiveDependencies,
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiServiceRef = ProviderRef<ApiService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$ApiServiceRouter(ApiService service) {
  final router = Router();
  router.add('GET', r'/', service._getIndex);
  router.mount(r'/earthquake', service._earthquakeApi.call);
  return router;
}
