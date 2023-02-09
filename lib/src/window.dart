import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWindow {
  static final Map<Object, YaruWindowInstance> _windows = {};

  static YaruWindowInstance instance([int id = 0]) {
    return _windows[id] ??= YaruWindowInstance._(id);
  }

  static YaruWindowInstance of(BuildContext context) {
    const id = 0; // View.of(context).windowId;
    return instance(id);
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

  static Future<void> maximize(BuildContext context) {
    return YaruWindow.of(context).maximize();
  }

  static Future<void> minimize(BuildContext context) {
    return YaruWindow.of(context).minimize();
  }

  static Future<void> restore(BuildContext context) {
    return YaruWindow.of(context).restore();
  }

  static Future<void> showMenu(BuildContext context) {
    return YaruWindow.of(context).showMenu();
  }

  static Future<void> unfullscreen(BuildContext context) {
    return YaruWindow.of(context).unfullscreen();
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

  static Future<void> maybePop(BuildContext context) {
    return Navigator.maybePop(context);
  }

  static Future<void> ensureInitialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb) {
      return YaruWindow.instance(0).init();
    }
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
  Future<void> maximize() => _platform.maximize(_id);
  Future<void> minimize() => _platform.minimize(_id);
  Future<void> restore() => _platform.restore(_id);
  Future<void> showMenu() => _platform.showMenu(_id);
  Future<void> unfullscreen() => _platform.unfullscreen(_id);

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
  Stream<YaruWindowState> states() => _platform.states(_id);
}
