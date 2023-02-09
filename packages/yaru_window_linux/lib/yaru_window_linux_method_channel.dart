import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'yaru_window_linux_platform_interface.dart';

/// An implementation of [YaruWindowLinuxPlatform] that uses method channels.
class MethodChannelYaruWindowLinux extends YaruWindowLinuxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('yaru_window_linux');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
