import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:yaru_window_platform_interface/src/method_channel.dart';
import 'package:yaru_window_platform_interface/src/platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('instance', () {
    expect(YaruWindowPlatform.instance, isA<YaruWindowMethodChannel>());
    YaruWindowPlatform.instance = MockYaruWindowPlatform();
    expect(YaruWindowPlatform.instance, isA<MockYaruWindowPlatform>());
  });

  test('unimplemented', () async {
    YaruWindowPlatform.instance = FakeYaruWindowPlatform();
    await expectLater(
      () => YaruWindowPlatform.instance.init(0),
      throwsUnimplementedError('init'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.close(0),
      throwsUnimplementedError('close'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.drag(0),
      throwsUnimplementedError('drag'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.fullscreen(0),
      throwsUnimplementedError('fullscreen'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.hide(0),
      throwsUnimplementedError('hide'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.hideTitle(0),
      throwsUnimplementedError('hideTitle'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.maximize(0),
      throwsUnimplementedError('maximize'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.minimize(0),
      throwsUnimplementedError('minimize'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.restore(0),
      throwsUnimplementedError('restore'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.show(0),
      throwsUnimplementedError('show'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.showMenu(0),
      throwsUnimplementedError('showMenu'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.showTitle(0),
      throwsUnimplementedError('showTitle'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.setBackground(0, Colors.black),
      throwsUnimplementedError('setBackground'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.setBrightness(0, Brightness.light),
      throwsUnimplementedError('setBrightness'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.setTitle(0, ''),
      throwsUnimplementedError('setTitle'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.setMinimizable(0, true),
      throwsUnimplementedError('setMinimizable'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.setMaximizable(0, true),
      throwsUnimplementedError('setMaximizable'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.setClosable(0, true),
      throwsUnimplementedError('setClosable'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.state(0),
      throwsUnimplementedError('state'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.states(0),
      throwsUnimplementedError('states'),
    );
    await expectLater(
      () => YaruWindowPlatform.instance.onClose(0, () => false),
      throwsUnimplementedError('onClose'),
    );
  });
}

class MockYaruWindowPlatform
    with Mock, MockPlatformInterfaceMixin
    implements YaruWindowPlatform {}

class FakeYaruWindowPlatform extends YaruWindowPlatform {}

Matcher throwsUnimplementedError(String method) => throwsA(
    isA<UnimplementedError>().having((e) => e.message, 'method', method),);
