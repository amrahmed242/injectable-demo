// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../features/async_demo/database_service.dart' as _i1;
import '../features/environment_demo/api_client.dart' as _i2;
import '../features/environment_demo/dev_api_client.dart' as _i3;
import '../features/environment_demo/prod_api_client.dart' as _i4;
import '../features/factory_demo/counter_service.dart' as _i5;
import '../features/lazy_singleton_demo/analytics_service.dart' as _i6;
import '../features/module_demo/app_module.dart' as _i7;
import '../features/module_demo/http_service.dart' as _i8;
import '../features/named_demo/console_logger.dart' as _i9;
import '../features/named_demo/logger.dart' as _i10;
import '../features/named_demo/remote_logger.dart' as _i11;
import '../features/singleton_demo/app_state_service.dart' as _i12;

extension GetItInjectableX on _i174.GetIt {
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _i7.AppModule();
    gh.factory<_i5.CounterService>(() => _i5.CounterService());
    gh.singleton<_i12.AppStateService>(() => _i12.AppStateService());
    gh.lazySingleton<_i6.AnalyticsService>(() => _i6.AnalyticsService());
    gh.factory<_i10.Logger>(
      () => _i9.ConsoleLogger(),
      instanceName: 'console',
    );
    gh.factory<_i10.Logger>(
      () => _i11.RemoteLogger(),
      instanceName: 'remote',
    );
    gh.factory<_i2.ApiClient>(
      () => _i3.DevApiClient(),
      registerFor: {_i526.Environment.dev},
    );
    gh.factory<_i2.ApiClient>(
      () => _i4.ProdApiClient(),
      registerFor: {_i526.Environment.prod},
    );
    gh.singleton<_i8.HttpService>(() => appModule.httpService);
    gh.lazySingletonAsync<_i1.DatabaseService>(
      () => _i1.DatabaseService.init(),
    );
    return this;
  }
}
