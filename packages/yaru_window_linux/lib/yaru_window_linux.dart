
import 'yaru_window_linux_platform_interface.dart';

class YaruWindowLinux {
  Future<String?> getPlatformVersion() {
    return YaruWindowLinuxPlatform.instance.getPlatformVersion();
  }
}
