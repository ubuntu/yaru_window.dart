import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWindowManager extends YaruWindowPlatform {
  YaruWindowManager([@visibleForTesting this.__wm]);

  static void registerWith() {
    YaruWindowPlatform.instance = YaruWindowManager();
  }

  _YaruWindowListener? __listener;
  _YaruWindowListener get _listener => __listener ??= _YaruWindowListener(_wm);

  WindowManager? __wm;
  WindowManager get _wm => __wm ??= WindowManager.instance;

  @override
  Future<void> init(int id) => _wm.ensureInitialized().catchError((_) {});

  @override
  Future<void> close(int id) => _wm.close().catchError((_) {});
  @override
  Future<void> drag(int id) => _wm.startDragging().catchError((_) {});
  @override
  Future<void> fullscreen(int id) => _wm.setFullScreen(true).catchError((_) {});
  @override
  Future<void> hide(int id) => _wm.hide().catchError((_) {});
  @override
  Future<void> hideTitle(int id) => _wm
      .setTitleBarStyle(TitleBarStyle.hidden)
      .catchError((_) {})
      .then((_) => _listener._updateState());
  @override
  Future<void> maximize(int id) => _wm.maximize().catchError((_) {});
  @override
  Future<void> minimize(int id) => _wm.minimize().catchError((_) {});
  @override
  Future<void> restore(int id) async {
    if (await _wm.isFullScreen()) {
      return _wm.setFullScreen(false).catchError((_) {});
    } else if (await _wm.isMaximized()) {
      return _wm.unmaximize().catchError((_) {});
    } else if (await _wm.isMinimized()) {
      return _wm.restore().catchError((_) {});
    }
  }

  @override
  Future<void> show(int id) => _wm.show().catchError((_) {});
  @override
  Future<void> showMenu(int id) => _wm.popUpWindowMenu().catchError((_) {});
  @override
  Future<void> showTitle(int id) => _wm
      .setTitleBarStyle(TitleBarStyle.normal)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setBackground(int id, Color color) => _wm
      .setBackgroundColor(color)
      .catchError((_) {})
      .then((_) => _listener._updateState());
  @override
  Future<void> setTitle(int id, String title) => _wm
      .setTitle(title)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setMinimizable(int id, bool minimizable) => _wm
      .setMinimizable(minimizable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setMaximizable(int id, bool maximizable) => _wm
      .setMaximizable(maximizable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setClosable(int id, bool closable) => _wm
      .setClosable(closable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<YaruWindowState> state(int id) => _wm.state();
  @override
  Stream<YaruWindowState> states(int id) => _listener.states();
}

extension _YaruWindowManagerX on WindowManager {
  Future<T> _invokeGetter<T>(
    Future<T> Function() getter, {
    required T orElse,
  }) async {
    try {
      return await getter();
    } on MissingPluginException catch (_) {
      return orElse;
    }
  }

  Future<YaruWindowState> state() {
    return Future.wait([
      _invokeGetter(isFocused, orElse: true),
      _invokeGetter(isClosable, orElse: true),
      _invokeGetter(isFullScreen, orElse: false),
      _invokeGetter(isMaximizable, orElse: true),
      _invokeGetter(isMaximized, orElse: false),
      _invokeGetter(isMinimizable, orElse: true),
      _invokeGetter(isMinimized, orElse: false),
      _invokeGetter(isMovable, orElse: true),
      _invokeGetter(getTitle, orElse: ''),
      _invokeGetter(isVisible, orElse: true),
    ]).then((values) {
      final active = values[0] as bool;
      final closable = values[1] as bool;
      final fullscreen = values[2] as bool;
      final maximizable = values[3] as bool;
      final maximized = values[4] as bool;
      final minimizable = values[5] as bool;
      final minimized = values[6] as bool;
      final movable = values[7] as bool;
      final title = values[8] as String;
      final visible = values[9] as bool;
      return YaruWindowState(
        isActive: active,
        isClosable: closable,
        isFullscreen: fullscreen,
        isMaximizable: maximizable && !maximized,
        isMaximized: maximized,
        isMinimizable: minimizable && !minimized,
        isMinimized: minimized,
        isMovable: movable && !kIsWeb,
        isRestorable: fullscreen || maximized || minimized,
        title: title,
        isVisible: visible,
      );
    });
  }
}

class _YaruWindowListener extends WindowListener {
  _YaruWindowListener(this._wm);

  final WindowManager _wm;
  StreamController<YaruWindowState>? _controller;

  Stream<YaruWindowState> states() async* {
    _controller ??= StreamController<YaruWindowState>.broadcast(
      onListen: () => _wm.addListener(this),
      onCancel: () => _wm.removeListener(this),
    );
    yield* _controller!.stream;
  }

  Future<void> close() async => await _controller?.close();

  Future<void> _updateState() async {
    _controller?.add(await _wm.state());
  }

  @override
  void onWindowBlur() => _updateState();
  @override
  void onWindowFocus() => _updateState();
  @override
  void onWindowEnterFullScreen() => _updateState();
  @override
  void onWindowLeaveFullScreen() => _updateState();
  @override
  void onWindowMaximize() => _updateState();
  @override
  void onWindowUnmaximize() => _updateState();
  @override
  void onWindowMinimize() => _updateState();
  @override
  void onWindowRestore() => _updateState();
}
