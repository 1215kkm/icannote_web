import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Settings screen with all app configuration options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final subState = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults.')),
              );
            },
            child: const Text('Reset All'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXXL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme section
                _SectionHeader(title: 'Appearance', icon: Icons.palette),
                _SettingsCard(
                  children: [
                    _DropdownSetting<AppThemeMode>(
                      title: 'Theme',
                      subtitle: 'Choose light or dark mode',
                      value: settings.themeMode,
                      items: const [
                        DropdownMenuItem(
                          value: AppThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.dark,
                          child: Text('Dark'),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.system,
                          child: Text('System'),
                        ),
                      ],
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setThemeMode(v!),
                    ),
                    const Divider(height: 1),
                    _DropdownSetting<String>(
                      title: 'Cursor Style',
                      subtitle: 'Canvas cursor appearance',
                      value: settings.cursorStyle,
                      items: const [
                        DropdownMenuItem(
                            value: 'default', child: Text('Default')),
                        DropdownMenuItem(
                            value: 'crosshair', child: Text('Crosshair')),
                        DropdownMenuItem(value: 'dot', child: Text('Dot')),
                      ],
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setCursorStyle(v!),
                    ),
                    const Divider(height: 1),
                    _SwitchSetting(
                      title: 'Show Toolbar Labels',
                      subtitle: 'Display text labels on toolbar buttons',
                      value: settings.showToolbarLabels,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setShowToolbarLabels(v),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Language section
                _SectionHeader(title: 'Language', icon: Icons.language),
                _SettingsCard(
                  children: [
                    _DropdownSetting<AppLanguage>(
                      title: 'Language',
                      subtitle: 'App display language',
                      value: settings.language,
                      items: AppLanguage.values
                          .map((l) => DropdownMenuItem(
                                value: l,
                                child: Text(l.label),
                              ))
                          .toList(),
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setLanguage(v!),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Auto-save section
                _SectionHeader(title: 'Save', icon: Icons.save),
                _SettingsCard(
                  children: [
                    _SwitchSetting(
                      title: 'Auto-Save',
                      subtitle: 'Automatically save lecture periodically',
                      value: settings.autoSaveEnabled,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setAutoSave(v),
                    ),
                    if (settings.autoSaveEnabled) ...[
                      const Divider(height: 1),
                      _SliderSetting(
                        title: 'Auto-Save Interval',
                        subtitle:
                            'Save every ${settings.autoSaveIntervalSeconds} seconds',
                        value: settings.autoSaveIntervalSeconds.toDouble(),
                        min: 10,
                        max: 120,
                        divisions: 11,
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .setAutoSaveInterval(v.round()),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Keyboard shortcuts section
                _SectionHeader(
                    title: 'Keyboard Shortcuts', icon: Icons.keyboard),
                _SettingsCard(
                  children: [
                    ...settings.shortcuts.asMap().entries.map((entry) {
                      final i = entry.key;
                      final shortcut = entry.value;
                      return Column(
                        children: [
                          if (i > 0) const Divider(height: 1),
                          _ShortcutSetting(binding: shortcut),
                        ],
                      );
                    }),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingMD),
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.read(settingsProvider.notifier).resetShortcuts(),
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Reset to Defaults'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Subscription section
                _SectionHeader(
                    title: 'Subscription', icon: Icons.card_membership),
                _SettingsCard(
                  children: [
                    ListTile(
                      title: const Text('Current Plan'),
                      subtitle: Text(
                        subState.currentPlan.name.toUpperCase(),
                        style: TextStyle(
                          color: subState.isActive
                              ? AppColors.secondary
                              : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => context.go('/subscription'),
                        child: Text(subState.isActive
                            ? 'Manage'
                            : 'Upgrade'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXXL),

                // App info
                Center(
                  child: Text(
                    'ICanNote v1.0.0',
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeSM,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingMD),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLG,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: AppDimensions.fontSizeMD)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: AppDimensions.fontSizeSM, color: Colors.grey.shade500)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _DropdownSetting<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: AppDimensions.fontSizeMD)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: AppDimensions.fontSizeSM, color: Colors.grey.shade500)),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: AppDimensions.fontSizeMD)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle,
              style: TextStyle(
                  fontSize: AppDimensions.fontSizeSM,
                  color: Colors.grey.shade500)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ShortcutSetting extends StatelessWidget {
  final ShortcutBinding binding;

  const _ShortcutSetting({required this.binding});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(binding.label,
          style: const TextStyle(fontSize: AppDimensions.fontSizeMD)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingSM,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          _formatActivator(binding.activator),
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeSM,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  String _formatActivator(SingleActivator activator) {
    final parts = <String>[];
    if (activator.control) parts.add('Ctrl');
    if (activator.shift) parts.add('Shift');
    if (activator.alt) parts.add('Alt');
    if (activator.meta) parts.add('Meta');

    final keyLabel = activator.trigger.keyLabel;
    parts.add(keyLabel.isNotEmpty ? keyLabel : activator.trigger.debugName ?? '?');

    return parts.join('+');
  }
}
