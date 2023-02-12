import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWebWindow extends YaruWindowPlatform {
  static void registerWith(Registrar? registrar) {
    YaruWindowPlatform.instance = YaruWebWindow();
  }

  @override
  Future<void> init(int id) async {}

  @override
  Future<void> close(int id) async {}
  @override
  Future<void> drag(int id) async {}
  @override
  Future<void> fullscreen(int id) async {}
  @override
  Future<void> hide(int id) async {}
  @override
  Future<void> hideTitle(int id) async {}
  @override
  Future<void> maximize(int id) async {}
  @override
  Future<void> minimize(int id) async {}
  @override
  Future<void> restore(int id) async {}
  @override
  Future<void> show(int id) async {}
  @override
  Future<void> showMenu(int id) async {}
  @override
  Future<void> showTitle(int id) async {}

  @override
  Future<void> setBackground(int id, Color color) async {}
  @override
  Future<void> setTitle(int id, String title) async {}
  @override
  Future<void> setMinimizable(int id, bool minimizable) async {}
  @override
  Future<void> setMaximizable(int id, bool maximizable) async {}
  @override
  Future<void> setClosable(int id, bool closable) async {}
  @override
  Future<YaruWindowState> state(int id) async => const YaruWindowState();
  @override
  Stream<YaruWindowState> states(int id) => const Stream.empty();

  @override
  void onClose(int id, FutureOr<bool> Function() handler) {}
}
