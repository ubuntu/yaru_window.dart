import 'dart:async';
import 'dart:ui';

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

  Future<void> init(int id) => throw UnimplementedError('init');

  Future<void> close(int id) => throw UnimplementedError('close');
  Future<void> drag(int id) => throw UnimplementedError('drag');
  Future<void> fullscreen(int id) => throw UnimplementedError('fullscreen');
  Future<void> hide(int id) => throw UnimplementedError('hide');
  Future<void> hideTitle(int id) => throw UnimplementedError('hideTitle');
  Future<void> maximize(int id) => throw UnimplementedError('maximize');
  Future<void> minimize(int id) => throw UnimplementedError('minimize');
  Future<void> restore(int id) => throw UnimplementedError('restore');
  Future<void> show(int id) => throw UnimplementedError('show');
  Future<void> showMenu(int id) => throw UnimplementedError('showMenu');
  Future<void> showTitle(int id) => throw UnimplementedError('showTitle');

  Future<void> setBackground(int id, Color color) =>
      throw UnimplementedError('setBackground');
  Future<void> setTitle(int id, String title) =>
      throw UnimplementedError('setTitle');
  Future<void> setMinimizable(int id, bool minimizable) =>
      throw UnimplementedError('setMinimizable');
  Future<void> setMaximizable(int id, bool maximizable) =>
      throw UnimplementedError('setMaximizable');
  Future<void> setClosable(int id, bool closable) =>
      throw UnimplementedError('setClosable');

  Future<YaruWindowState> state(int id) => throw UnimplementedError('state');
  Stream<YaruWindowState> states(int id) => throw UnimplementedError('states');

  void onClose(int id, FutureOr<bool> Function() handler) {
    throw UnimplementedError('onClose');
  }
}
