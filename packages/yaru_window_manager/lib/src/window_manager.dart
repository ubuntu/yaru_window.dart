import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWindowManager extends YaruWindowPlatform {
  static void registerWith() {
    YaruWindowPlatform.instance = YaruWindowManager();
  }

  _YaruWindowListener? __listener;
  _YaruWindowListener get _listener => __listener ??= _YaruWindowListener(wm);

  static WindowManager? _wm;
  static WindowManager get wm => _wm ??= WindowManager.instance;

  @override
  Future<void> init(int id) => wm.ensureInitialized();

  @override
  Future<void> close(int id) => wm.close().catchError((_) {});
  @override
  Future<void> drag(int id) => wm.startDragging().catchError((_) {});
  @override
  Future<void> fullscreen(int id) => wm.setFullScreen(true).catchError((_) {});
  @override
  Future<void> maximize(int id) => wm.maximize().catchError((_) {});
  @override
  Future<void> minimize(int id) => wm.minimize().catchError((_) {});
  @override
  Future<void> restore(int id) async {
    if (await wm.isFullScreen()) {
      return wm.setFullScreen(false).catchError((_) {});
    } else if (await wm.isMaximized()) {
      return wm.unmaximize().catchError((_) {});
    } else if (await wm.isMinimized()) {
      return wm.restore().catchError((_) {});
    }
  }

  @override
  Future<void> showMenu(int id) => wm.popUpWindowMenu().catchError((_) {});

  @override
  Future<void> setBackground(int id, Color color) => wm
      .setBackgroundColor(color)
      .catchError((_) {})
      .then((_) => _listener._updateState());
  @override
  Future<void> setTitle(int id, String title) => wm
      .setTitle(title)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setMinimizable(int id, bool minimizable) => wm
      .setMinimizable(minimizable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setMaximizable(int id, bool maximizable) => wm
      .setMaximizable(maximizable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<void> setClosable(int id, bool closable) => wm
      .setClosable(closable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  @override
  Future<YaruWindowState> state(int id) => wm.state();
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
      );
    });
  }
}

class _YaruWindowListener implements WindowListener {
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
  @override
  void onWindowClose() {}
  @override
  void onWindowResize() {}
  @override
  void onWindowResized() {}
  @override
  void onWindowMove() {}
  @override
  void onWindowMoved() {}
  @override
  void onWindowEvent(String eventName) {}
}
