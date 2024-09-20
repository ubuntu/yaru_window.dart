import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yaru_window/yaru_window.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('state', (tester) async {
    final window = await YaruWindow.ensureInitialized();
    expect(
      await window.state(),
      isA<YaruWindowState>()
          .having((s) => s.isActive, 'active', anyOf(isTrue, isFalse))
          .having((s) => s.isClosable, 'closable', isTrue)
          .having((s) => s.isFullscreen, 'fullscreen', isFalse)
          .having((s) => s.isMaximizable, 'maximizable', isTrue)
          .having((s) => s.isMaximized, 'maximized', isFalse)
          .having((s) => s.isMinimizable, 'minimizable', isTrue)
          .having((s) => s.isMinimized, 'minimized', isFalse)
          .having((s) => s.isMovable, 'movable', isTrue)
          .having((s) => s.isRestorable, 'restorable', isFalse)
          .having((s) => s.title, 'title', 'Yaru Window')
          .having((s) => s.isVisible, 'visible', isTrue),
    );
  });
}
