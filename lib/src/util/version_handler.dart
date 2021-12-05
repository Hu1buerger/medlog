import 'package:package_info_plus/package_info_plus.dart';

class VersionHandler {
  static VersionHandler Instance = VersionHandler();

  Future<PackageInfo> pkgInfo = PackageInfo.fromPlatform();

  Future<String> getVersion() async {
    var info = await pkgInfo;
    return info.version;
  }
}
