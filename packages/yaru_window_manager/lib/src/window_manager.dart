import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWindowManager extends YaruWindowPlatform {
  static void registerWith() {
    YaruWindowPlatform.instance = YaruWindowManager();
  }

  final _listener = _YaruWindowListener(wm);

  @visibleForTesting
  static WindowManager wm = WindowManager.instance;

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
  Future<void> restore(int id) => wm.unmaximize().catchError((_) {});
  @override
  Future<void> showMenu(int id) => wm.popUpWindowMenu().catchError((_) {});
  @override
  Future<void> unfullscreen(int id) =>
      wm.setFullScreen(false).catchError((_) {});

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
        isClosable: closable && !Platform.isMacOS,
        isFullscreen: fullscreen,
        isMaximizable: maximizable && !maximized && !Platform.isMacOS,
        isMaximized: maximized,
        isMinimizable: minimizable && !minimized && !Platform.isMacOS,
        isMinimized: minimized,
        isMovable: movable && !kIsWeb,
        isRestorable:
            (fullscreen || maximized || minimized) && !Platform.isMacOS,
        title: title,
      );
    });
  }
}

class _YaruWindowListener implements WindowListener {
  _YaruWindowListener(this._wm);

  final WindowManager _wm;
  StreamController<YaruWindowState>? _controller;
  YaruWindowState? _state;

  YaruWindowState? get state => _state;

  Stream<YaruWindowState> states() async* {
    _controller ??= StreamController<YaruWindowState>.broadcast(
      onListen: () => _wm.addListener(this),
      onCancel: () => _wm.removeListener(this),
    );
    if (_state == null) {
      _state = await _wm.state();
      yield _state!;
    }
    yield* _controller!.stream;
  }

  Future<void> close() async => await _controller?.close();

  Future<void> _updateState() async {
    _state = await _wm.state();
    _controller?.add(_state!);
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
