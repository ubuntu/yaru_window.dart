import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

Future<void> main() async {
  await YaruWindow.ensureInitialized();

  runApp(
    YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
        );
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    YaruWindow.of(context).onClose(() => showConfirmationDialog(context));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Expanded(child: ColorSelector()),
          Expanded(child: StateView()),
        ],
      ),
    );
  }
}

Future<bool> showConfirmationDialog(BuildContext context) async {
  if (!context.mounted) return true;
  if (ModalRoute.of(context)?.isCurrent == false) return false;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Close window?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
        ],
      );
    },
  ).then((value) => value == true);
}

class StateView extends StatelessWidget {
  const StateView({super.key});

  @override
  Widget build(BuildContext context) {
    final window = YaruWindow.of(context);
    return StreamBuilder<YaruWindowState>(
      stream: window.states(),
      builder: (context, snapshot) {
        final state = snapshot.data;
        debugPrint(state?.toString());
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ListTile(
              title: const Text('Active'),
              subtitle: Text('${state?.isActive}'),
            ),
            ListTile(
              title: const Text('Brightness'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => window.setBrightness(Brightness.light),
                    child: const Text('Light'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => window.setBrightness(Brightness.dark),
                    child: const Text('Dark'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Closable'),
              subtitle: Text('${state?.isClosable}'),
              trailing: ElevatedButton(
                onPressed: (state?.isClosable ?? false) ? window.close : null,
                child: const Text('Close'),
              ),
            ),
            ListTile(
              title: const Text('Fullscreen'),
              subtitle: Text('${state?.isFullscreen}'),
              trailing: ElevatedButton(
                onPressed:
                    state?.isFullscreen != true ? window.fullscreen : null,
                child: const Text('Fullscreen'),
              ),
            ),
            ListTile(
              title: Text(
                'Maximizable ${(state?.isMaximized ?? false) ? '(maximized)' : ''}',
              ),
              subtitle: Text('${state?.isMaximizable}'),
              trailing: ElevatedButton(
                onPressed:
                    (state?.isMaximizable ?? false) ? window.maximize : null,
                child: const Text('Maximize'),
              ),
            ),
            ListTile(
              title: Text(
                'Minimizable ${(state?.isMinimized ?? false) ? '(minimized)' : ''}',
              ),
              subtitle: Text('${state?.isMinimizable}'),
              trailing: ElevatedButton(
                onPressed:
                    (state?.isMinimizable ?? false) ? window.minimize : null,
                child: const Text('Minimize'),
              ),
            ),
            ListTile(
              title: const Text('Movable'),
              subtitle: Text('${state?.isMovable}'),
              trailing: GestureDetector(
                onPanStart: (_) => window.drag(),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Drag'),
                ),
              ),
            ),
            ListTile(
              title: const Text('Restorable'),
              subtitle: Text('${state?.isRestorable}'),
              trailing: ElevatedButton(
                onPressed:
                    (state?.isRestorable ?? false) ? window.restore : null,
                child: const Text('Restore'),
              ),
            ),
            ListTile(
              title: const Text('Menu'),
              trailing: ElevatedButton(
                onPressed: window.showMenu,
                child: const Text('Show'),
              ),
            ),
            ListTile(
              title: const Text('Title'),
              subtitle: Text('${state?.title}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: window.showTitle,
                    child: const Text('Show'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: window.hideTitle,
                    child: const Text('Hide'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Title'),
                          content: TextFormField(
                            autofocus: true,
                            initialValue: state?.title,
                            onFieldSubmitted: Navigator.of(context).pop,
                            onChanged: window.setTitle,
                          ),
                        ),
                      );
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Visible'),
              subtitle: Text('${state?.isVisible}'),
              trailing: ElevatedButton(
                onPressed: () => window
                    .hide()
                    .then((_) => Future.delayed(const Duration(seconds: 2)))
                    .then((_) => window.show()),
                child: const Text('Hide 2s'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ColorSelector extends StatefulWidget {
  const ColorSelector({super.key});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Color? _color;

  @override
  Widget build(BuildContext context) {
    _color ??= Theme.of(context).colorScheme.surface;
    return Column(
      children: [
        const Spacer(),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text('Color'),
          ),
        ),
        ColorPicker(
          color: _color!,
          enableShadesSelection: false,
          pickersEnabled: const {
            ColorPickerType.accent: false,
            ColorPickerType.primary: false,
            ColorPickerType.custom: false,
            ColorPickerType.wheel: true,
          },
          onColorChanged: (color) {
            setState(() => _color = color.withValues(alpha: _color!.a));
            YaruWindow.of(context).setBackground(_color!);
          },
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text('Opacity'),
          ),
        ),
        Slider(
          value: _color!.a,
          onChanged: (value) {
            setState(() => _color = _color!.withValues(alpha: value));
            YaruWindow.of(context).setBackground(_color!);
          },
        ),
        const Spacer(),
      ],
    );
  }
}
