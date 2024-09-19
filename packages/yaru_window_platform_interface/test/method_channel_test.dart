import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaru_window_platform_interface/src/method_channel.dart';

import 'state_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  test('init', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'init');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.init(123);
  });

  test('close', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'close');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.close(123);
  });

  test('drag', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'drag');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.drag(123);
  });

  test('fullscreen', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'fullscreen');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.fullscreen(123);
  });

  test('hide', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'hide');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.hide(123);
  });

  test('hideTitle', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'hideTitle');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.hideTitle(123);
  });

  test('maximize', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'maximize');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.maximize(123);
  });

  test('minimize', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'minimize');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.minimize(123);
  });

  test('restore', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'restore');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.restore(123);
  });

  test('show', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'show');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.show(123);
  });

  test('showMenu', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'showMenu');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.showMenu(123);
  });

  test('showTitle', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'showTitle');
      expect(call.arguments, [123]);
      return null;
    });
    await instance.showTitle(123);
  });

  test('setBackground', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'setBackground');
      expect(call.arguments, [123, 0x11223344]);
      return null;
    });
    await instance.setBackground(123, const Color(0x11223344));
  });

  test('setBrightness', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'setBrightness');
      expect(call.arguments, [123, 'dark']);
      return null;
    });
    await instance.setBrightness(123, Brightness.dark);
  });

  test('setTitle', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'setTitle');
      expect(call.arguments, [123, 'foo bar']);
      return null;
    });
    await instance.setTitle(123, 'foo bar');
  });

  test('setMinimizable', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'setMinimizable');
      expect(call.arguments, [123, true]);
      return null;
    });
    await instance.setMinimizable(123, true);
  });

  test('setMaximizable', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'setMaximizable');
      expect(call.arguments, [123, true]);
      return null;
    });
    await instance.setMaximizable(123, true);
  });

  test('setClosable', () async {
    final instance = YaruWindowMethodChannel();
    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'setClosable');
      expect(call.arguments, [123, true]);
      return null;
    });
    await instance.setClosable(123, true);
  });

  test('state', () async {
    final instance = YaruWindowMethodChannel();

    messenger.setMockMethodCallHandler(instance.channel, (call) async {
      expect(call.method, 'state');
      expect(call.arguments, [123]);
      return testState.toJson();
    });

    expect(await instance.state(123), testState);
  });

  test('broadcast state events', () async {
    final instance = YaruWindowMethodChannel();

    const codec = StandardMethodCodec();
    final channel = instance.events.name;

    Future<void> emitEvent(Object? event) {
      return messenger.handlePlatformMessage(
        channel,
        codec.encodeSuccessEnvelope(event),
        (_) {},
      );
    }

    messenger.setMockMessageHandler(channel, (message) async {
      expect(
        codec.decodeMethodCall(message),
        anyOf([
          isMethodCall('listen', arguments: null),
          isMethodCall('cancel', arguments: null),
        ]),
      );
      return codec.encodeSuccessEnvelope(null);
    });

    instance.states(123).listen(expectAsync1((ev) => expect(ev, testState)));
    instance.states(123).listen(expectAsync1((ev) => expect(ev, testState)));

    final event = testState.toJson();
    event['id'] = 123;
    event['type'] = 'state';
    await emitEvent(event);
  });

  testWidgets('onClose', (tester) async {
    final instance = YaruWindowMethodChannel();

    var wasCalled = 0;
    await instance.onClose(0, () => ++wasCalled > 1);

    expect(await WidgetsBinding.instance.handleRequestAppExit(),
        AppExitResponse.cancel,);
    expect(wasCalled, 1);

    expect(await WidgetsBinding.instance.handleRequestAppExit(),
        AppExitResponse.exit,);
    expect(wasCalled, 2);
  });
}
