import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ioc.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: r'$initIoc',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() => $initIoc(sl);

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}