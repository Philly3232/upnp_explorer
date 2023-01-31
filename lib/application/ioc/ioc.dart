import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../infrastructure/upnp/search_request_builder.dart';
import 'ioc.config.dart';

final GetIt sl = GetIt.instance;

@InjectableInit(
  asExtension: false,
)
Future<void> configureDependencies({
  required String environment,
}) async {
  await init(
    sl,
    environment: environment,
  );
}

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @preResolve
  Future<UserAgentBuilder> get userAgentBuilder => UserAgentBuilder.create();

  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();
}
