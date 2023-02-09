import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

class YaruWindow {
  static final Map<Object, _YaruWindowInstance> _windows = {};

  static _YaruWindowInstance of(BuildContext context) {
    const id = 0; // View.of(context).windowId;
    return _windows[id] ??= _YaruWindowInstance._(id);
  }

  static Future<void> close(BuildContext context) {
    return YaruWindow.of(context).close();
  }

  static Future<void> drag(BuildContext context) {
    return YaruWindow.of(context).drag();
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
      await windowManager.ensureInitialized();
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
  }
}

class _YaruWindowInstance {
  _YaruWindowInstance._(this._id);

  final Object _id; // ignore: unused_field
  final _listener = _YaruWindowListener(wm);

  @visibleForTesting
  static WindowManager wm = WindowManager.instance;

  Future<void> close() => wm.close().catchError((_) {});
  Future<void> drag() => wm.startDragging().catchError((_) {});
  Future<void> maximize() => wm.maximize().catchError((_) {});
  Future<void> minimize() => wm.minimize().catchError((_) {});
  Future<void> restore() => wm.unmaximize().catchError((_) {});
  Future<void> showMenu() => wm.popUpWindowMenu().catchError((_) {});

  Future<void> setTitle(String title) => wm
      .setTitle(title)
      .catchError((_) {})
      .then((_) => _listener._updateState());
  Future<void> setMinimizable(bool minimizable) => wm
      .setMinimizable(minimizable)
      .catchError((_) {})
      .then((_) => _listener._updateState());
  Future<void> setMaximizable(bool maximizable) => wm
      .setMaximizable(maximizable)
      .catchError((_) {})
      .then((_) => _listener._updateState());
  Future<void> setClosable(bool closable) => wm
      .setClosable(closable)
      .catchError((_) {})
      .then((_) => _listener._updateState());

  Future<YaruWindowState> state() => wm.state();
  Stream<YaruWindowState> states() => _listener.states();
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
