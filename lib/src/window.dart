import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

/// Provides access to the closest top-level window instance that encloses the
/// given context.
class YaruWindow {
  static final Map<Object, YaruWindowInstance> _windows = {};

  static YaruWindowInstance _instance([int id = 0]) {
    return _windows[id] ??= YaruWindowInstance._(id);
  }

  /// Returns the closest top-level window instance that encloses the given
  /// context.
  static YaruWindowInstance of(BuildContext context) {
    const id = 0; // View.of(context).windowId;
    return _instance(id);
  }

  /// Closes the window.
  static Future<void> close(BuildContext context) {
    return YaruWindow.of(context).close();
  }

  /// Starts dragging the window.
  static Future<void> drag(BuildContext context) {
    return YaruWindow.of(context).drag();
  }

  /// Enters fullscreen mode.
  static Future<void> fullscreen(BuildContext context) {
    return YaruWindow.of(context).fullscreen();
  }

  /// Hides the window.
  static Future<void> hide(BuildContext context) {
    return YaruWindow.of(context).hide();
  }

  /// Hides the title bar.
  static Future<void> hideTitle(BuildContext context) {
    return YaruWindow.of(context).hideTitle();
  }

  /// Maximizes the window.
  static Future<void> maximize(BuildContext context) {
    return YaruWindow.of(context).maximize();
  }

  /// Minimizes the window.
  static Future<void> minimize(BuildContext context) {
    return YaruWindow.of(context).minimize();
  }

  /// Restores the window to its normal state.
  static Future<void> restore(BuildContext context) {
    return YaruWindow.of(context).restore();
  }

  /// Shows the window.
  static Future<void> show(BuildContext context) {
    return YaruWindow.of(context).show();
  }

  /// Shows the window menu.
  static Future<void> showMenu(BuildContext context) {
    return YaruWindow.of(context).showMenu();
  }

  /// Shows the title bar.
  static Future<void> showTitle(BuildContext context) {
    return YaruWindow.of(context).showTitle();
  }

  /// Sets the background color of the window.
  static Future<void> setBackground(BuildContext context, Color color) {
    return YaruWindow.of(context).setBackground(color);
  }

  /// Sets the brightness of the window.
  static Future<void> setBrightness(
    BuildContext context,
    Brightness brightness,
  ) {
    return YaruWindow.of(context).setBrightness(brightness);
  }

  /// Sets the title of the window.
  static Future<void> setTitle(BuildContext context, String title) {
    return YaruWindow.of(context).setTitle(title);
  }

  /// Sets whether the window can be minimized.
  static Future<void> setMinimizable(BuildContext context, bool minimizable) {
    return YaruWindow.of(context).setMinimizable(minimizable);
  }

  /// Sets whether the window can be maximized.
  static Future<void> setMaximizable(BuildContext context, bool maximizable) {
    return YaruWindow.of(context).setMaximizable(maximizable);
  }

  /// Sets whether the window can be closed.
  static Future<void> setClosable(BuildContext context, bool closable) {
    return YaruWindow.of(context).setClosable(closable);
  }

  /// Returns the current state of the window.
  static Future<YaruWindowState> state(BuildContext context) {
    return YaruWindow.of(context).state();
  }

  /// Returns a stream of window state changes.
  static Stream<YaruWindowState> states(BuildContext context) {
    return YaruWindow.of(context).states();
  }

  /// Installs a close handler for the window.
  static Future<void> onClose(
    BuildContext context,
    FutureOr<bool> Function() handler,
  ) {
    return YaruWindow.of(context).onClose(handler);
  }

  /// Ensures that the window is initialized and returns the primary instance.
  static Future<YaruWindowInstance> ensureInitialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    final window = YaruWindow._instance(0);
    await window.init();
    return window;
  }
}

/// A top-level window instance.
class YaruWindowInstance {
  YaruWindowInstance._(this._id);

  final int _id; // ignore: unused_field

  YaruWindowPlatform get _platform => YaruWindowPlatform.instance;

  /// Initializes the window.
  Future<void> init() => _platform.init(_id);

  /// Closes the window.
  Future<void> close() => _platform.close(_id);

  /// Starts dragging the window.
  Future<void> drag() => _platform.drag(_id);

  /// Enters fullscreen mode.
  Future<void> fullscreen() => _platform.fullscreen(_id);

  /// Hides the window.
  Future<void> hide() => _platform.hide(_id);

  /// Hides the title bar.
  Future<void> hideTitle() => _platform.hideTitle(_id);

  /// Maximizes the window.
  Future<void> maximize() => _platform.maximize(_id);

  /// Minimizes the window.
  Future<void> minimize() => _platform.minimize(_id);

  /// Restores the window to its normal state.
  Future<void> restore() => _platform.restore(_id);

  /// Shows the window.
  Future<void> show() => _platform.show(_id);

  /// Shows the window menu.
  Future<void> showMenu() => _platform.showMenu(_id);

  /// Shows the title bar.
  Future<void> showTitle() => _platform.showTitle(_id);

  /// Sets the background color of the window.
  Future<void> setBackground(Color color) {
    return _platform.setBackground(_id, color);
  }

  /// Sets the brightness of the window.
  Future<void> setBrightness(Brightness brightness) {
    return _platform.setBrightness(_id, brightness);
  }

  /// Sets the title of the window.
  Future<void> setTitle(String title) => _platform.setTitle(_id, title);

  /// Sets whether the window can be minimized.
  Future<void> setMinimizable(bool minimizable) {
    return _platform.setMinimizable(_id, minimizable);
  }

  /// Sets whether the window can be maximized.
  Future<void> setMaximizable(bool maximizable) {
    return _platform.setMaximizable(_id, maximizable);
  }

  /// Sets whether the window can be closed.
  Future<void> setClosable(bool closable) {
    return _platform.setClosable(_id, closable);
  }

  /// Returns the current state of the window.
  Future<YaruWindowState> state() => _platform.state(_id);

  /// Returns a stream of window state changes.
  Stream<YaruWindowState> states() async* {
    yield await _platform.state(_id);
    yield* _platform.states(_id);
  }

  /// Installs a close handler for the window.
  Future<void> onClose(FutureOr<bool> Function() handler) async {
    WidgetsBinding.instance.addObserver(_YaruWindowObserver(handler));
  }
}

class _YaruWindowObserver with WidgetsBindingObserver {
  _YaruWindowObserver(this.handler);

  final FutureOr<bool> Function() handler;

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    return await handler() ? AppExitResponse.exit : AppExitResponse.cancel;
  }
}
