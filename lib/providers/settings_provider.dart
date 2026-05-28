import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App theme mode.
enum AppThemeMode { light, dark, system }

/// Supported languages.
enum AppLanguage {
  english('en', 'English'),
  korean('ko', '한국어');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);
}

/// A customizable keyboard shortcut binding.
class ShortcutBinding {
  final String action;
  final String label;
  final SingleActivator activator;

  const ShortcutBinding({
    required this.action,
    required this.label,
    required this.activator,
  });

  ShortcutBinding copyWith({SingleActivator? activator}) {
    return ShortcutBinding(
      action: action,
      label: label,
      activator: activator ?? this.activator,
    );
  }
}

/// Default keyboard shortcuts.
List<ShortcutBinding> defaultShortcuts() => [
      const ShortcutBinding(
        action: 'undo',
        label: 'Undo',
        activator: SingleActivator(LogicalKeyboardKey.keyZ, control: true),
      ),
      const ShortcutBinding(
        action: 'redo',
        label: 'Redo',
        activator: SingleActivator(LogicalKeyboardKey.keyY, control: true),
      ),
      const ShortcutBinding(
        action: 'redo_alt',
        label: 'Redo (Alt)',
        activator: SingleActivator(LogicalKeyboardKey.keyZ,
            control: true, shift: true),
      ),
      const ShortcutBinding(
        action: 'save',
        label: 'Save',
        activator: SingleActivator(LogicalKeyboardKey.keyS, control: true),
      ),
      const ShortcutBinding(
        action: 'copy',
        label: 'Copy',
        activator: SingleActivator(LogicalKeyboardKey.keyC, control: true),
      ),
      const ShortcutBinding(
        action: 'paste',
        label: 'Paste',
        activator: SingleActivator(LogicalKeyboardKey.keyV, control: true),
      ),
      const ShortcutBinding(
        action: 'delete',
        label: 'Delete',
        activator: SingleActivator(LogicalKeyboardKey.delete),
      ),
      const ShortcutBinding(
        action: 'select_all',
        label: 'Select All',
        activator: SingleActivator(LogicalKeyboardKey.keyA, control: true),
      ),
      const ShortcutBinding(
        action: 'pen',
        label: 'Pen Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyP),
      ),
      const ShortcutBinding(
        action: 'eraser',
        label: 'Eraser Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyE),
      ),
      const ShortcutBinding(
        action: 'text',
        label: 'Text Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyT),
      ),
      const ShortcutBinding(
        action: 'selection',
        label: 'Selection Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyS),
      ),
      const ShortcutBinding(
        action: 'hand',
        label: 'Pan/Hand Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyH),
      ),
      const ShortcutBinding(
        action: 'line',
        label: 'Line Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyL),
      ),
      const ShortcutBinding(
        action: 'rectangle',
        label: 'Rectangle Tool',
        activator: SingleActivator(LogicalKeyboardKey.keyR),
      ),
    ];

class SettingsState {
  final AppThemeMode themeMode;
  final AppLanguage language;
  final List<ShortcutBinding> shortcuts;
  final bool showToolbarLabels;
  final bool autoSaveEnabled;
  final int autoSaveIntervalSeconds;
  final String cursorStyle; // 'default', 'crosshair', 'dot'

  const SettingsState({
    this.themeMode = AppThemeMode.light,
    this.language = AppLanguage.english,
    this.shortcuts = const [],
    this.showToolbarLabels = false,
    this.autoSaveEnabled = true,
    this.autoSaveIntervalSeconds = 30,
    this.cursorStyle = 'default',
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    List<ShortcutBinding>? shortcuts,
    bool? showToolbarLabels,
    bool? autoSaveEnabled,
    int? autoSaveIntervalSeconds,
    String? cursorStyle,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      shortcuts: shortcuts ?? this.shortcuts,
      showToolbarLabels: showToolbarLabels ?? this.showToolbarLabels,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      autoSaveIntervalSeconds:
          autoSaveIntervalSeconds ?? this.autoSaveIntervalSeconds,
      cursorStyle: cursorStyle ?? this.cursorStyle,
    );
  }

  bool get isDarkMode => themeMode == AppThemeMode.dark;

  /// Build the shortcut bindings map for CallbackShortcuts.
  Map<SingleActivator, VoidCallback> buildShortcutMap(
      Map<String, VoidCallback> actions) {
    final map = <SingleActivator, VoidCallback>{};
    for (final binding in shortcuts) {
      final action = actions[binding.action];
      if (action != null) {
        map[binding.activator] = action;
      }
    }
    return map;
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(shortcuts: defaultShortcuts()));

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void setShowToolbarLabels(bool show) {
    state = state.copyWith(showToolbarLabels: show);
  }

  void setAutoSave(bool enabled) {
    state = state.copyWith(autoSaveEnabled: enabled);
  }

  void setAutoSaveInterval(int seconds) {
    state = state.copyWith(autoSaveIntervalSeconds: seconds);
  }

  void setCursorStyle(String style) {
    state = state.copyWith(cursorStyle: style);
  }

  /// Update a shortcut binding.
  void updateShortcut(String action, SingleActivator newActivator) {
    final updated = state.shortcuts.map((s) {
      if (s.action == action) {
        return s.copyWith(activator: newActivator);
      }
      return s;
    }).toList();
    state = state.copyWith(shortcuts: updated);
  }

  /// Reset all shortcuts to defaults.
  void resetShortcuts() {
    state = state.copyWith(shortcuts: defaultShortcuts());
  }

  /// Reset all settings to defaults.
  void resetAll() {
    state = SettingsState(shortcuts: defaultShortcuts());
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
