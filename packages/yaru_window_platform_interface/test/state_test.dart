import 'package:flutter_test/flutter_test.dart';
import 'package:yaru_window_platform_interface/src/state.dart';

void main() {
  test('equality', () {
    expect(testState, testState);
    expect(testState.hashCode, testState.hashCode);

    expect(testState, isNot(otherState));
    expect(testState.hashCode, isNot(otherState.hashCode));
  });

  test('copy with', () {
    expect(testState.copyWith(), testState);
    expect(testState.copyWith(isActive: false, title: 'baz qux'), otherState);
  });

  test('merge', () {
    expect(testState.merge(partialState), otherState);
  });
}

const testState = YaruWindowState(
  isActive: true,
  isClosable: true,
  isFullscreen: false,
  isMaximizable: true,
  isMaximized: false,
  isMinimizable: true,
  isMinimized: false,
  isMovable: true,
  isRestorable: false,
  title: 'foo bar',
  isVisible: true,
);

const otherState = YaruWindowState(
  isActive: false,
  isClosable: true,
  isFullscreen: false,
  isMaximizable: true,
  isMaximized: false,
  isMinimizable: true,
  isMinimized: false,
  isMovable: true,
  isRestorable: false,
  title: 'baz qux',
  isVisible: true,
);

const partialState = YaruWindowState(
  isActive: false,
  title: 'baz qux',
);
