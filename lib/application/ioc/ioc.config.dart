// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_info_plus/device_info_plus.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i14;
import 'package:upnp_explorer/application/changelog/changelog_service.dart'
    as _i16;
import 'package:upnp_explorer/application/device/current_device.dart' as _i17;
import 'package:upnp_explorer/application/device/device_repository.dart' as _i7;
import 'package:upnp_explorer/application/device/service_repository.dart'
    as _i13;
import 'package:upnp_explorer/application/ioc/ioc.dart' as _i26;
import 'package:upnp_explorer/application/logging/logger_factory.dart' as _i8;
import 'package:upnp_explorer/application/logging/logging_bloc_observer.dart'
    as _i9;
import 'package:upnp_explorer/application/network_logs/network_logs_repository.dart'
    as _i11;
import 'package:upnp_explorer/application/review/review_service.dart' as _i19;
import 'package:upnp_explorer/application/settings/options_repository.dart'
    as _i20;
import 'package:upnp_explorer/domain/device/device_repository_type.dart' as _i6;
import 'package:upnp_explorer/domain/device/service_repository_type.dart'
    as _i12;
import 'package:upnp_explorer/domain/network_logs/network_logs_repository_type.dart'
    as _i10;
import 'package:upnp_explorer/infrastructure/core/bug_report_service.dart'
    as _i4;
import 'package:upnp_explorer/infrastructure/core/download_service.dart'
    as _i18;
import 'package:upnp_explorer/infrastructure/upnp/device_discovery_service.dart'
    as _i23;
import 'package:upnp_explorer/infrastructure/upnp/search_request_builder.dart'
    as _i15;
import 'package:upnp_explorer/infrastructure/upnp/soap_service.dart' as _i21;
import 'package:upnp_explorer/infrastructure/upnp/ssdp_discovery.dart' as _i24;
import 'package:upnp_explorer/presentation/core/bloc/application_bloc.dart'
    as _i3;
import 'package:upnp_explorer/presentation/device/bloc/discovery_bloc.dart'
    as _i25;
import 'package:upnp_explorer/presentation/service/bloc/command_bloc.dart'
    as _i22;

/// ignore_for_file: unnecessary_lambdas
/// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of main-scope dependencies inside of [GetIt]
Future<_i1.GetIt> init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i3.ApplicationBloc>(() => _i3.ApplicationBloc());
  gh.lazySingleton<_i4.BugReportService>(() => _i4.BugReportService());
  gh.factory<_i5.DeviceInfoPlugin>(() => registerModule.deviceInfoPlugin);
  gh.lazySingleton<_i6.DeviceRepositoryType>(
    () => _i7.DeviceRepository(),
    instanceName: 'DeviceRepository',
  );
  gh.lazySingleton<_i8.LoggerFactory>(() => _i8.LoggerFactory());
  gh.lazySingleton<_i9.LoggingBlocObserver>(
      () => _i9.LoggingBlocObserver(gh<_i8.LoggerFactory>()));
  gh.lazySingleton<_i10.NetworkLogsRepositoryType>(
      () => _i11.NetworkLogsRepository());
  gh.lazySingleton<_i12.ServiceRepositoryType>(
    () => _i13.ServiceRepository(),
    instanceName: 'ServiceRepository',
  );
  await gh.factoryAsync<_i14.SharedPreferences>(
    () => registerModule.prefs,
    preResolve: true,
  );
  await gh.factoryAsync<_i15.UserAgentBuilder>(
    () => registerModule.userAgentBuilder,
    preResolve: true,
  );
  gh.lazySingleton<_i16.ChangelogService>(
      () => _i16.ChangelogService(gh<_i14.SharedPreferences>()));
  await gh.singletonAsync<_i17.CurrentDeviceInfo>(
    () => _i17.CurrentDeviceInfo.create(gh<_i5.DeviceInfoPlugin>()),
    preResolve: true,
  );
  gh.lazySingleton<_i18.DownloadService>(
      () => _i18.DownloadService(gh<_i8.LoggerFactory>()));
  gh.lazySingleton<_i19.ReviewService>(
      () => _i19.ReviewService(gh<_i14.SharedPreferences>()));
  gh.lazySingleton<_i15.SearchRequestBuilder>(
      () => _i15.SearchRequestBuilder(gh<_i15.UserAgentBuilder>()));
  gh.lazySingleton<_i20.SettingsRepository>(
      () => _i20.SettingsRepository(gh<_i14.SharedPreferences>()));
  gh.lazySingleton<_i21.SoapService>(() => _i21.SoapService(
        gh<_i15.UserAgentBuilder>(),
        gh<_i10.NetworkLogsRepositoryType>(),
      ));
  gh.lazySingleton<_i22.CommandBloc>(
      () => _i22.CommandBloc(gh<_i21.SoapService>()));
  gh.lazySingleton<_i23.DeviceDiscoveryService>(
      () => _i23.DeviceDiscoveryService(
            gh<_i8.LoggerFactory>(),
            gh<_i10.NetworkLogsRepositoryType>(),
            gh<_i15.SearchRequestBuilder>(),
          ));
  gh.lazySingleton<_i24.SSDPService>(() => _i24.NetworkSSDPService(
        gh<_i23.DeviceDiscoveryService>(),
        gh<_i18.DownloadService>(),
        gh<_i8.LoggerFactory>(),
        gh<_i6.DeviceRepositoryType>(instanceName: 'DeviceRepository'),
        gh<_i12.ServiceRepositoryType>(instanceName: 'ServiceRepository'),
        gh<_i10.NetworkLogsRepositoryType>(),
      ));
  gh.lazySingleton<_i25.DiscoveryBloc>(
      () => _i25.DiscoveryBloc(gh<_i24.SSDPService>()));
  return getIt;
}

class _$RegisterModule extends _i26.RegisterModule {}
