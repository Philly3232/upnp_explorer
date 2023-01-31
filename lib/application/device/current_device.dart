import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

const minimumMaterialYouSdkVersion = 31;

@Singleton()
class CurrentDeviceInfo {
  final int sdkVersion;

  get supportsMaterial3 =>
      Platform.isAndroid && sdkVersion >= minimumMaterialYouSdkVersion;

  CurrentDeviceInfo(this.sdkVersion);

  @preResolve
  @factoryMethod
  static Future<CurrentDeviceInfo> create(DeviceInfoPlugin plugin) async {
    final info = await plugin.androidInfo;

    return CurrentDeviceInfo(info.version.sdkInt);
  }
}
