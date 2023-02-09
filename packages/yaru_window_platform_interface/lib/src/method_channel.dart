import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'platform_interface.dart';
import 'state.dart';

class YaruWindowMethodChannel extends YaruWindowPlatform {
  @visibleForTesting
  final channel = const MethodChannel('yaru_window');

  @visibleForTesting
  final events = const EventChannel('yaru_window/events');

  @override
  Future<void> close(int id) => _invokeMethod('close', [id]);
  @override
  Future<void> drag(int id) => _invokeMethod('drag', [id]);
  @override
  Future<void> fullscreen(int id) => _invokeMethod('fullscreen', [id]);
  @override
  Future<void> hide(int id) => _invokeMethod('hide', [id]);
  @override
  Future<void> hideTitle(int id) => _invokeMethod('hideTitle', [id]);
  @override
  Future<void> init(int id) => _invokeMethod('init', [id]);
  @override
  Future<void> maximize(int id) => _invokeMethod('maximize', [id]);
  @override
  Future<void> minimize(int id) => _invokeMethod('minimize', [id]);
  @override
  Future<void> restore(int id) => _invokeMethod('restore', [id]);
  @override
  Future<void> show(int id) => _invokeMethod('show', [id]);
  @override
  Future<void> showMenu(int id) => _invokeMethod('showMenu', [id]);
  @override
  Future<YaruWindowState> state(int id) =>
      _invokeMapMethod('state', [id]).then(YaruWindowState.fromJson);
  @override
  Stream<YaruWindowState> states(int id) =>
      _receiveEvents(id, 'state').map(YaruWindowState.fromJson);
  @override
  Future<void> setState(int id, YaruWindowState state) {
    return _invokeMethod('state', [id, state]);
  }

  Future<T?> _invokeMethod<T>(String method, [dynamic args]) {
    return channel.invokeMethod<T>(method, args);
  }

  Future<Map<String, dynamic>> _invokeMapMethod(String method, [dynamic args]) {
    return channel
        .invokeMapMethod<String, dynamic>(method, args)
        .then((v) => v!);
  }

  Stream<Map>? _events;
  Stream<Map<String, dynamic>> _receiveEvents(int id, String type) {
    _events ??= events.receiveBroadcastStream().cast<Map>();
    return _events!
        .where((event) => event['id'] == id && event['type'] == type)
        .map((event) => event.cast<String, dynamic>());
  }
}
