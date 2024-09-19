import 'package:meta/meta.dart';

/// The state of a window.
@immutable
class YaruWindowState {
  /// Creates a new [YaruWindowState].
  const YaruWindowState({
    this.isActive,
    this.isClosable,
    this.isFullscreen,
    this.isMaximizable,
    this.isMaximized,
    this.isMinimizable,
    this.isMinimized,
    this.isMovable,
    this.isRestorable,
    this.title,
    this.isVisible,
  });

  /// Creates a new [YaruWindowState] from a JSON object.
  factory YaruWindowState.fromJson(Map<String, dynamic> json) {
    return YaruWindowState(
      isActive: json['active'] as bool?,
      isClosable: json['closable'] as bool?,
      isFullscreen: json['fullscreen'] as bool?,
      isMaximizable: json['maximizable'] as bool?,
      isMaximized: json['maximized'] as bool?,
      isMinimizable: json['minimizable'] as bool?,
      isMinimized: json['minimized'] as bool?,
      isMovable: json['movable'] as bool?,
      isRestorable: json['restorable'] as bool?,
      title: json['title'] as String?,
      isVisible: json['visible'] as bool?,
    );
  }

  /// Whether the window is active.
  final bool? isActive;

  /// Whether the window is closable.
  final bool? isClosable;

  /// Whether the window is fullscreen.
  final bool? isFullscreen;

  /// Whether the window is maximizable.
  final bool? isMaximizable;

  /// Whether the window is maximized.
  final bool? isMaximized;

  /// Whether the window is minimizable.
  final bool? isMinimizable;

  /// Whether the window is minimized.
  final bool? isMinimized;

  /// Whether the window is movable.
  final bool? isMovable;

  /// Whether the window is restorable.
  final bool? isRestorable;

  /// The title of the window.
  final String? title;

  /// Whether the window is visible.
  final bool? isVisible;

  /// Converts the state to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'active': isActive,
      'closable': isClosable,
      'fullscreen': isFullscreen,
      'maximizable': isMaximizable,
      'maximized': isMaximized,
      'minimizable': isMinimizable,
      'minimized': isMinimized,
      'movable': isMovable,
      'restorable': isRestorable,
      'title': title,
      'visible': isVisible,
    };
  }

  /// Copies the state with the specified fields replaced with new values.
  YaruWindowState copyWith({
    bool? isActive,
    bool? isClosable,
    bool? isFullscreen,
    bool? isMaximizable,
    bool? isMaximized,
    bool? isMinimizable,
    bool? isMinimized,
    bool? isMovable,
    bool? isRestorable,
    String? title,
    bool? isVisible,
  }) {
    return YaruWindowState(
      isActive: isActive ?? this.isActive,
      isClosable: isClosable ?? this.isClosable,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isMaximizable: isMaximizable ?? this.isMaximizable,
      isMaximized: isMaximized ?? this.isMaximized,
      isMinimizable: isMinimizable ?? this.isMinimizable,
      isMinimized: isMinimized ?? this.isMinimized,
      isMovable: isMovable ?? this.isMovable,
      isRestorable: isRestorable ?? this.isRestorable,
      title: title ?? this.title,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Merges the state with another [YaruWindowState].
  YaruWindowState merge(YaruWindowState? other) {
    return copyWith(
      isActive: other?.isActive,
      isClosable: other?.isClosable,
      isFullscreen: other?.isFullscreen,
      isMaximizable: other?.isMaximizable,
      isMaximized: other?.isMaximized,
      isMinimizable: other?.isMinimizable,
      isMinimized: other?.isMinimized,
      isMovable: other?.isMovable,
      isRestorable: other?.isRestorable,
      title: other?.title,
      isVisible: other?.isVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YaruWindowState &&
        other.isActive == isActive &&
        other.isClosable == isClosable &&
        other.isFullscreen == isFullscreen &&
        other.isMaximizable == isMaximizable &&
        other.isMaximized == isMaximized &&
        other.isMinimizable == isMinimizable &&
        other.isMinimized == isMinimized &&
        other.isMovable == isMovable &&
        other.isRestorable == isRestorable &&
        other.title == title &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode {
    return Object.hash(
      isActive,
      isClosable,
      isFullscreen,
      isMaximizable,
      isMaximized,
      isMinimizable,
      isMinimized,
      isMovable,
      isRestorable,
      title,
      isVisible,
    );
  }

  @override
  String toString() {
    return 'YaruWindowState(isActive: $isActive, isClosable: $isClosable, isFullscreen: $isFullscreen, isMaximizable: $isMaximizable, isMaximized: $isMaximized, isMinimizable: $isMinimizable, isMinimized: $isMinimized, isMovable: $isMovable, isRestorable: $isRestorable, title: $title, isVisible: $isVisible)';
  }
}
