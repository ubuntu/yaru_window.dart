import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'yaru_window_linux_method_channel.dart';

abstract class YaruWindowLinuxPlatform extends PlatformInterface {
  /// Constructs a YaruWindowLinuxPlatform.
  YaruWindowLinuxPlatform() : super(token: _token);

  static final Object _token = Object();

  static YaruWindowLinuxPlatform _instance = MethodChannelYaruWindowLinux();

  /// The default instance of [YaruWindowLinuxPlatform] to use.
  ///
  /// Defaults to [MethodChannelYaruWindowLinux].
  static YaruWindowLinuxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [YaruWindowLinuxPlatform] when
  /// they register themselves.
  static set instance(YaruWindowLinuxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
