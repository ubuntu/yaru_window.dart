import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru_window_manager/src/window_manager.dart';
import 'package:yaru_window_platform_interface/yaru_window_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Color(0xff000000));
    registerFallbackValue(Brightness.dark);
    registerFallbackValue(TitleBarStyle.normal);
    registerFallbackValue(FakeWindowListener());
  });

  test('register', () {
    YaruWindowManager.registerWith();
    expect(YaruWindowPlatform.instance, isA<YaruWindowManager>());
  });

  test('methods', () async {
    final wm = MockWindowManager();
    when(wm.ensureInitialized).thenAnswer((_) async {});
    when(wm.close).thenAnswer((_) async {});
    when(wm.startDragging).thenAnswer((_) async {});
    when(() => wm.setFullScreen(any())).thenAnswer((_) async {});
    when(wm.hide).thenAnswer((_) async {});
    when(() => wm.setTitleBarStyle(any())).thenAnswer((_) async {});
    when(wm.maximize).thenAnswer((_) async {});
    when(wm.minimize).thenAnswer((_) async {});
    when(wm.show).thenAnswer((_) async {});
    when(wm.popUpWindowMenu).thenAnswer((_) async {});
    when(() => wm.setTitle(any())).thenAnswer((_) async {});
    when(() => wm.setBackgroundColor(any())).thenAnswer((_) async {});
    when(() => wm.setBrightness(any())).thenAnswer((_) async {});
    when(() => wm.setMinimizable(any())).thenAnswer((_) async {});
    when(() => wm.setMaximizable(any())).thenAnswer((_) async {});
    when(() => wm.setClosable(any())).thenAnswer((_) async {});

    YaruWindowPlatform.instance = YaruWindowManager(wm);

    await YaruWindowPlatform.instance.init(0);
    verify(wm.ensureInitialized).called(1);

    await YaruWindowPlatform.instance.close(0);
    verify(wm.close).called(1);

    await YaruWindowPlatform.instance.drag(0);
    verify(wm.startDragging).called(1);

    await YaruWindowPlatform.instance.fullscreen(0);
    verify(() => wm.setFullScreen(true)).called(1);

    await YaruWindowPlatform.instance.hide(0);
    verify(wm.hide).called(1);

    await YaruWindowPlatform.instance.hideTitle(0);
    verify(() => wm.setTitleBarStyle(TitleBarStyle.hidden)).called(1);

    await YaruWindowPlatform.instance.maximize(0);
    verify(wm.maximize).called(1);

    await YaruWindowPlatform.instance.minimize(0);
    verify(wm.minimize).called(1);

    await YaruWindowPlatform.instance.show(0);
    verify(wm.show).called(1);

    await YaruWindowPlatform.instance.showMenu(0);
    verify(wm.popUpWindowMenu).called(1);

    await YaruWindowPlatform.instance.showTitle(0);
    verify(() => wm.setTitleBarStyle(TitleBarStyle.normal)).called(1);

    await YaruWindowPlatform.instance.setBackground(0, Colors.black);
    verify(() => wm.setBackgroundColor(Colors.black)).called(1);

    await YaruWindowPlatform.instance.setBrightness(0, Brightness.dark);
    verify(() => wm.setBrightness(Brightness.dark)).called(1);

    await YaruWindowPlatform.instance.setTitle(0, 'foo bar');
    verify(() => wm.setTitle('foo bar')).called(1);

    await YaruWindowPlatform.instance.setMinimizable(0, true);
    verify(() => wm.setMinimizable(true)).called(1);

    await YaruWindowPlatform.instance.setMaximizable(0, true);
    verify(() => wm.setMaximizable(true)).called(1);

    await YaruWindowPlatform.instance.setClosable(0, true);
    verify(() => wm.setClosable(true)).called(1);
  });

  test('restore', () async {
    final wm = MockWindowManager();
    when(wm.restore).thenAnswer((_) async {});
    when(wm.unmaximize).thenAnswer((_) async {});
    when(() => wm.setFullScreen(any())).thenAnswer((_) async {});

    YaruWindowPlatform.instance = YaruWindowManager(wm);

    when(wm.isFullScreen).thenAnswer((_) async => true);
    when(wm.isMaximized).thenAnswer((_) async => false);
    when(wm.isMinimized).thenAnswer((_) async => false);

    await YaruWindowPlatform.instance.restore(0);
    verify(() => wm.setFullScreen(false)).called(1);

    when(wm.isFullScreen).thenAnswer((_) async => false);
    when(wm.isMaximized).thenAnswer((_) async => true);
    when(wm.isMinimized).thenAnswer((_) async => false);

    await YaruWindowPlatform.instance.restore(0);
    verify(wm.unmaximize).called(1);

    when(wm.isFullScreen).thenAnswer((_) async => false);
    when(wm.isMaximized).thenAnswer((_) async => false);
    when(wm.isMinimized).thenAnswer((_) async => true);

    await YaruWindowPlatform.instance.restore(0);
    verify(wm.restore).called(1);
  });

  test('state', () async {
    final wm = mockWindowManager(title: 'foo bar');
    YaruWindowPlatform.instance = YaruWindowManager(wm);

    final state = await YaruWindowPlatform.instance.state(0);
    expect(state.isActive, isTrue);
    expect(state.isClosable, isTrue);
    expect(state.isFullscreen, isFalse);
    expect(state.isMaximizable, isTrue);
    expect(state.isMaximized, isFalse);
    expect(state.isMinimized, isFalse);
    expect(state.isMaximizable, isTrue);
    expect(state.isMovable, isTrue);
    expect(state.title, 'foo bar');
    expect(state.isVisible, isTrue);
  });

  test('states', () async {
    final wm = mockWindowManager();
    when(() => wm.addListener(any())).thenAnswer((i) {
      final listener = i.positionalArguments[0] as WindowListener;

      when(wm.isFocused).thenAnswer((_) async => false);
      listener.onWindowBlur();

      when(wm.isFocused).thenAnswer((_) async => true);
      listener.onWindowFocus();

      when(wm.isFullScreen).thenAnswer((_) async => true);
      listener.onWindowEnterFullScreen();

      when(wm.isFullScreen).thenAnswer((_) async => false);
      listener.onWindowLeaveFullScreen();

      when(wm.isMaximized).thenAnswer((_) async => true);
      listener.onWindowMaximize();

      when(wm.isMaximized).thenAnswer((_) async => false);
      listener.onWindowUnmaximize();

      when(wm.isMinimized).thenAnswer((_) async => true);
      listener.onWindowMinimize();

      when(wm.isMinimized).thenAnswer((_) async => false);
      listener.onWindowRestore();
    });

    YaruWindowPlatform.instance = YaruWindowManager(wm);

    expect(
      YaruWindowPlatform.instance.states(0),
      emitsInOrder(
        [
          isWindowState(isActive: false),
          isWindowState(isActive: true),
          isWindowState(isFullscreen: true),
          isWindowState(isFullscreen: false),
          isWindowState(isMaximized: true),
          isWindowState(isMaximized: false),
          isWindowState(isMinimized: true),
          isWindowState(isMinimized: false),
        ],
      ),
    );
  });
}

class FakeWindowListener extends Fake implements WindowListener {}

class MockWindowManager extends Mock implements WindowManager {}

MockWindowManager mockWindowManager({
  bool isActive = true,
  bool isClosable = true,
  bool isFullscreen = false,
  bool isMaximizable = true,
  bool isMaximized = false,
  bool isMinimizable = true,
  bool isMinimized = false,
  bool isMovable = true,
  String title = '',
  bool isVisible = true,
}) {
  final wm = MockWindowManager();
  when(wm.isClosable).thenAnswer((_) async => isClosable);
  when(wm.isFocused).thenAnswer((_) async => isActive);
  when(wm.isFullScreen).thenAnswer((_) async => isFullscreen);
  when(wm.isMaximizable).thenAnswer((_) async => isMaximizable);
  when(wm.isMaximized).thenAnswer((_) async => isMaximized);
  when(wm.isMinimizable).thenAnswer((_) async => isMinimizable);
  when(wm.isMinimized).thenAnswer((_) async => isMinimized);
  when(wm.isMovable).thenAnswer((_) async => isMovable);
  when(wm.getTitle).thenAnswer((_) async => title);
  when(wm.isVisible).thenAnswer((_) async => isVisible);
  return wm;
}

Matcher isWindowState({
  bool? isActive,
  bool? isFullscreen,
  bool? isMaximized,
  bool? isMinimized,
}) {
  var matcher = isA<YaruWindowState>();
  if (isActive != null) {
    matcher = matcher.having((s) => s.isActive, 'isActive', equals(isActive));
  }
  if (isFullscreen != null) {
    matcher = matcher.having(
        (s) => s.isFullscreen, 'isFullscreen', equals(isFullscreen));
  }
  if (isMaximized != null) {
    matcher = matcher.having(
        (s) => s.isMaximized, 'isMaximized', equals(isMaximized));
  }
  if (isMinimized != null) {
    matcher = matcher.having(
        (s) => s.isMinimized, 'isMinimized', equals(isMinimized));
  }
  return matcher;
}
