import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWindow {
  static final Map<Object, YaruWindowInstance> _windows = {};

  static YaruWindowInstance _instance([int id = 0]) {
    return _windows[id] ??= YaruWindowInstance._(id);
  }

  static YaruWindowInstance of(BuildContext context) {
    const id = 0; // View.of(context).windowId;
    return _instance(id);
  }

  static Future<void> close(BuildContext context) {
    return YaruWindow.of(context).close();
  }

  static Future<void> drag(BuildContext context) {
    return YaruWindow.of(context).drag();
  }

  static Future<void> fullscreen(BuildContext context) {
    return YaruWindow.of(context).fullscreen();
  }

  static Future<void> hide(BuildContext context) {
    return YaruWindow.of(context).hide();
  }

  static Future<void> hideTitle(BuildContext context) {
    return YaruWindow.of(context).hideTitle();
  }

  static Future<void> maximize(BuildContext context) {
    return YaruWindow.of(context).maximize();
  }

  static Future<void> minimize(BuildContext context) {
    return YaruWindow.of(context).minimize();
  }

  static Future<void> restore(BuildContext context) {
    return YaruWindow.of(context).restore();
  }

  static Future<void> show(BuildContext context) {
    return YaruWindow.of(context).show();
  }

  static Future<void> showMenu(BuildContext context) {
    return YaruWindow.of(context).showMenu();
  }

  static Future<void> showTitle(BuildContext context) {
    return YaruWindow.of(context).showTitle();
  }

  static Future<void> setBackground(BuildContext context, Color color) {
    return YaruWindow.of(context).setBackground(color);
  }

  static Future<void> setTitle(BuildContext context, String title) {
    return YaruWindow.of(context).setTitle(title);
  }

  static Future<void> setMinimizable(BuildContext context, bool minimizable) {
    return YaruWindow.of(context).setMinimizable(minimizable);
  }

  static Future<void> setMaximizable(BuildContext context, bool maximizable) {
    return YaruWindow.of(context).setMaximizable(maximizable);
  }

  static Future<void> setClosable(BuildContext context, bool closable) {
    return YaruWindow.of(context).setClosable(closable);
  }

  static Future<YaruWindowState> state(BuildContext context) {
    return YaruWindow.of(context).state();
  }

  static Stream<YaruWindowState> states(BuildContext context) {
    return YaruWindow.of(context).states();
  }

  static void onClose(BuildContext context, FutureOr<bool> Function() handler) {
    YaruWindow.of(context).onClose(handler);
  }

  static Future<YaruWindowInstance> ensureInitialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    final window = YaruWindow._instance(0);
    await window.init();
    return window;
  }
}

class YaruWindowInstance {
  YaruWindowInstance._(this._id);

  final int _id; // ignore: unused_field

  YaruWindowPlatform get _platform => YaruWindowPlatform.instance;

  Future<void> init() => _platform.init(_id);

  Future<void> close() => _platform.close(_id);
  Future<void> drag() => _platform.drag(_id);
  Future<void> fullscreen() => _platform.fullscreen(_id);
  Future<void> hide() => _platform.hide(_id);
  Future<void> hideTitle() => _platform.hideTitle(_id);
  Future<void> maximize() => _platform.maximize(_id);
  Future<void> minimize() => _platform.minimize(_id);
  Future<void> restore() => _platform.restore(_id);
  Future<void> show() => _platform.show(_id);
  Future<void> showMenu() => _platform.showMenu(_id);
  Future<void> showTitle() => _platform.showTitle(_id);

  Future<void> setBackground(Color color) =>
      _platform.setBackground(_id, color);
  Future<void> setTitle(String title) => _platform.setTitle(_id, title);
  Future<void> setMinimizable(bool minimizable) =>
      _platform.setMinimizable(_id, minimizable);
  Future<void> setMaximizable(bool maximizable) =>
      _platform.setMaximizable(_id, maximizable);
  Future<void> setClosable(bool closable) =>
      _platform.setClosable(_id, closable);

  Future<YaruWindowState> state() => _platform.state(_id);
  Stream<YaruWindowState> states() async* {
    yield await _platform.state(_id);
    yield* _platform.states(_id);
  }

  void onClose(FutureOr<bool> Function() handler) {
    _platform.onClose(_id, handler);
  }
}
