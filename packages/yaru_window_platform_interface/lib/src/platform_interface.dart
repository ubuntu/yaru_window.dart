import 'dart:async';
import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:yaru_window_platform_interface/src/method_channel.dart';
import 'package:yaru_window_platform_interface/src/state.dart';

/// A common platform interface for `yaru_window`.
abstract class YaruWindowPlatform extends PlatformInterface {
  /// Constructs a [YaruWindowPlatform].
  YaruWindowPlatform() : super(token: _token);

  static final Object _token = Object();
  static YaruWindowPlatform _instance = YaruWindowMethodChannel();

  /// The default instance of [YaruWindowPlatform] to use.
  static YaruWindowPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  static set instance(YaruWindowPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the window with the given [id].
  Future<void> init(int id) => throw UnimplementedError('init');

  /// Closes the window with the given [id].
  Future<void> close(int id) => throw UnimplementedError('close');

  /// Starts dragging the window with the given [id].
  Future<void> drag(int id) => throw UnimplementedError('drag');

  /// Enters fullscreen mode for the window with the given [id].
  Future<void> fullscreen(int id) => throw UnimplementedError('fullscreen');

  /// Hides the window with the given [id].
  Future<void> hide(int id) => throw UnimplementedError('hide');

  /// Hides the title bar of the window with the given [id].
  Future<void> hideTitle(int id) => throw UnimplementedError('hideTitle');

  /// Maximizes the window with the given [id].
  Future<void> maximize(int id) => throw UnimplementedError('maximize');

  /// Minimizes the window with the given [id].
  Future<void> minimize(int id) => throw UnimplementedError('minimize');

  /// Restores the window with the given [id].
  Future<void> restore(int id) => throw UnimplementedError('restore');

  /// Shows the window with the given [id].
  Future<void> show(int id) => throw UnimplementedError('show');

  /// Shows the menu of the window with the given [id].
  Future<void> showMenu(int id) => throw UnimplementedError('showMenu');

  /// Shows the title bar of the window with the given [id].
  Future<void> showTitle(int id) => throw UnimplementedError('showTitle');

  /// Sets the background color of the window with the given [id].
  Future<void> setBackground(int id, Color color) {
    throw UnimplementedError('setBackground');
  }

  /// Sets the brightness of the window with the given [id].
  Future<void> setBrightness(int id, Brightness brightness) {
    throw UnimplementedError('setBrightness');
  }

  /// Sets the title of the window with the given [id].
  Future<void> setTitle(int id, String title) {
    throw UnimplementedError('setTitle');
  }

  /// Sets whether the window with the given [id] is minimizable.
  Future<void> setMinimizable(int id, bool minimizable) {
    throw UnimplementedError('setMinimizable');
  }

  /// Sets whether the window with the given [id] is maximizable.
  Future<void> setMaximizable(int id, bool maximizable) {
    throw UnimplementedError('setMaximizable');
  }

  /// Sets whether the window with the given [id] is closable.
  Future<void> setClosable(int id, bool closable) {
    throw UnimplementedError('setClosable');
  }

  /// Returns the state of the window with the given [id].
  Future<YaruWindowState> state(int id) => throw UnimplementedError('state');

  /// Returns a stream of states of the window with the given [id].
  Stream<YaruWindowState> states(int id) => throw UnimplementedError('states');

  /// Installs a close handler for the window with the given [id].
  Future<void> onClose(int id, FutureOr<bool> Function() handler) {
    throw UnimplementedError('onClose');
  }
}
