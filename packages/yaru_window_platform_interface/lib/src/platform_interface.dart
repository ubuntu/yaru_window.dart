import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel.dart';
import 'state.dart';

abstract class YaruWindowPlatform extends PlatformInterface {
  YaruWindowPlatform() : super(token: _token);

  static final Object _token = Object();

  static YaruWindowPlatform get instance => _instance;
  static YaruWindowPlatform _instance = YaruWindowMethodChannel();
  static set instance(YaruWindowPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> close(int id) => throw UnimplementedError('close');
  Future<void> drag(int id) => throw UnimplementedError('drag');
  Future<void> fullscreen(int id) => throw UnimplementedError('fullscreen');
  Future<void> hide(int id) => throw UnimplementedError('hide');
  Future<void> hideTitle(int id) => throw UnimplementedError('hideTitle');
  Future<void> init(int id) => throw UnimplementedError('init');
  Future<void> maximize(int id) => throw UnimplementedError('maximize');
  Future<void> minimize(int id) => throw UnimplementedError('minimize');
  Future<void> restore(int id) => throw UnimplementedError('restore');
  Future<void> show(int id) => throw UnimplementedError('show');
  Future<void> showMenu(int id) => throw UnimplementedError('showMenu');

  Future<YaruWindowState> state(int id) => throw UnimplementedError('state');
  Stream<YaruWindowState> states(int id) => throw UnimplementedError('states');
  Future<void> setState(int id, YaruWindowState state) {
    throw UnimplementedError('setState');
  }
}
