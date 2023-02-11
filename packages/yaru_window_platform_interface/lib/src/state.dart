import 'package:meta/meta.dart';

@immutable
class YaruWindowState {
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

  factory YaruWindowState.fromJson(Map<String, dynamic> json) {
    return YaruWindowState(
      isActive: json['active'],
      isClosable: json['closable'],
      isFullscreen: json['fullscreen'],
      isMaximizable: json['maximizable'],
      isMaximized: json['maximized'],
      isMinimizable: json['minimizable'],
      isMinimized: json['minimized'],
      isMovable: json['movable'],
      isRestorable: json['restorable'],
      title: json['title'],
      isVisible: json['visible'],
    );
  }

  final bool? isActive;
  final bool? isClosable;
  final bool? isFullscreen;
  final bool? isMaximizable;
  final bool? isMaximized;
  final bool? isMinimizable;
  final bool? isMinimized;
  final bool? isMovable;
  final bool? isRestorable;
  final String? title;
  final bool? isVisible;

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
