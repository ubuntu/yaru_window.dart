import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

@visibleForTesting
class YaruTestWindow extends YaruWindowPlatform {
  static Future<void> ensureInitialized({YaruWindowState? state}) async {
    _state = state;
    _platform ??= YaruWindowPlatform.instance;
    if (YaruWindowPlatform.instance is! YaruTestWindow) {
      YaruWindowPlatform.instance = YaruTestWindow();
    }
  }

  static Future<void> waitForClosed() async {
    final window = YaruWindowPlatform.instance;
    assert(window is YaruTestWindow, 'Call YaruTestWindow.ensureInitialized');
    return (window as YaruTestWindow)._waitForClosed();
  }

  Future<void> _waitForClosed() async {
    final completer = Completer();
    _onCloseHandlers.add(() {
      completer.complete();
      return true;
    });
    return completer.future;
  }

  static YaruWindowState? _state;
  static YaruWindowPlatform? _platform;

  @override
  Future<void> init(int id) async => _platform?.init(id);

  @override
  Future<void> close(int id) async {
    while (_onCloseHandlers.isNotEmpty) {
      final handler = _onCloseHandlers.removeAt(0);
      if (!await handler()) {
        break;
      }
    }
  }

  @override
  Future<void> drag(int id) async => _platform?.drag(id);
  @override
  Future<void> fullscreen(int id) async => _platform?.fullscreen(id);
  @override
  Future<void> hide(int id) async => _platform?.hide(id);
  @override
  Future<void> hideTitle(int id) async => _platform?.hideTitle(id);
  @override
  Future<void> maximize(int id) async => _platform?.maximize(id);
  @override
  Future<void> minimize(int id) async => _platform?.minimize(id);
  @override
  Future<void> restore(int id) async => _platform?.restore(id);
  @override
  Future<void> show(int id) async => _platform?.show(id);
  @override
  Future<void> showMenu(int id) async => _platform?.showMenu(id);
  @override
  Future<void> showTitle(int id) async => _platform?.showTitle(id);

  @override
  Future<void> setBackground(int id, Color color) async {
    return _platform?.setBackground(id, color);
  }

  @override
  Future<void> setTitle(int id, String title) async {
    return _platform?.setTitle(id, title);
  }

  @override
  Future<void> setMinimizable(int id, bool minimizable) async {
    return _platform?.setMinimizable(id, minimizable);
  }

  @override
  Future<void> setMaximizable(int id, bool maximizable) async {
    return _platform?.setMaximizable(id, maximizable);
  }

  @override
  Future<void> setClosable(int id, bool closable) async {
    return _platform?.setClosable(id, closable);
  }

  @override
  Future<YaruWindowState> state(int id) async {
    return _state != null
        ? Future.value(_state)
        : _platform?.state(id) ?? Future.value(const YaruWindowState());
  }

  @override
  Stream<YaruWindowState> states(int id) {
    return _state != null
        ? Stream.value(_state!)
        : _platform?.states(id) ?? const Stream.empty();
  }

  @override
  Future<void> onClose(int id, FutureOr<bool> Function() handler) async {
    _onCloseHandlers.add(handler);
  }

  final _onCloseHandlers = <FutureOr<bool> Function()>[];
}
