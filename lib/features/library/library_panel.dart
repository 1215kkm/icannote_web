import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/canvas_element.dart';
import '../../providers/canvas_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// A saved page preset in the library.
class PagePreset {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Map<String, dynamic>> elementsJson;

  const PagePreset({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.elementsJson,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'elements': elementsJson,
      };

  factory PagePreset.fromJson(Map<String, dynamic> json) {
    return PagePreset(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      elementsJson: (json['elements'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}

/// State for the library.
class LibraryState {
  final List<PagePreset> presets;
  final bool isOpen;

  const LibraryState({
    this.presets = const [],
    this.isOpen = false,
  });

  LibraryState copyWith({
    List<PagePreset>? presets,
    bool? isOpen,
  }) {
    return LibraryState(
      presets: presets ?? this.presets,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier() : super(const LibraryState());

  void toggle() => state = state.copyWith(isOpen: !state.isOpen);
  void open() => state = state.copyWith(isOpen: true);
  void close() => state = state.copyWith(isOpen: false);

  /// Save current canvas elements as a preset.
  void savePreset(String name, List<CanvasElement> elements) {
    final preset = PagePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      elementsJson: elements.map((e) => e.toJson()).toList(),
    );

    state = state.copyWith(presets: [...state.presets, preset]);
  }

  /// Delete a preset.
  void deletePreset(String id) {
    state = state.copyWith(
      presets: state.presets.where((p) => p.id != id).toList(),
    );
  }

  /// Rename a preset.
  void renamePreset(String id, String newName) {
    state = state.copyWith(
      presets: state.presets.map((p) {
        if (p.id == id) {
          return PagePreset(
            id: p.id,
            name: newName,
            createdAt: p.createdAt,
            elementsJson: p.elementsJson,
          );
        }
        return p;
      }).toList(),
    );
  }

  /// Export presets as JSON string.
  String exportPresets() {
    return jsonEncode(state.presets.map((p) => p.toJson()).toList());
  }

  /// Import presets from JSON string.
  void importPresets(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      final presets =
          list.map((e) => PagePreset.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(presets: [...state.presets, ...presets]);
    } catch (e) {
      debugPrint('Failed to import presets: $e');
    }
  }
}

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});

/// Library panel overlay for managing page presets.
class LibraryPanel extends ConsumerStatefulWidget {
  const LibraryPanel({super.key});

  @override
  ConsumerState<LibraryPanel> createState() => _LibraryPanelState();
}

class _LibraryPanelState extends ConsumerState<LibraryPanel> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libState = ref.watch(libraryProvider);

    if (!libState.isOpen) return const SizedBox.shrink();

    return Positioned(
      right: AppDimensions.rightToolbarWidth + AppDimensions.spacingMD,
      top: AppDimensions.spacingMD,
      child: Container(
        width: 260,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: AppDimensions.shadowBlurMD,
              offset: const Offset(0, AppDimensions.shadowOffsetY),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMD),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.panelBorder),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.library_books, size: 16),
                  const SizedBox(width: AppDimensions.spacingMD),
                  const Text(
                    'Library',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontSizeMD,
                    ),
                  ),
                  const Spacer(),
                  // Save current page
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    tooltip: 'Save current page as preset',
                    onPressed: () => _showSaveDialog(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () =>
                        ref.read(libraryProvider.notifier).close(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Presets list
            if (libState.presets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingXXL),
                child: Text(
                  'No presets saved yet.\nSave current page with the + button.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeSM,
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: libState.presets.length,
                  itemBuilder: (context, index) {
                    final preset = libState.presets[index];
                    return _PresetTile(preset: preset);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog() {
    _nameController.text =
        'Preset ${ref.read(libraryProvider).presets.length + 1}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Preset'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final elements = ref.read(canvasProvider).elements;
                ref.read(libraryProvider.notifier).savePreset(name, elements);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _PresetTile extends ConsumerWidget {
  final PagePreset preset;

  const _PresetTile({required this.preset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      title: Text(
        preset.name,
        style: const TextStyle(fontSize: AppDimensions.fontSizeMD),
      ),
      subtitle: Text(
        '${preset.elementsJson.length} elements',
        style: TextStyle(
          fontSize: AppDimensions.fontSizeXS,
          color: Colors.grey.shade500,
        ),
      ),
      leading: const Icon(Icons.insert_drive_file, size: 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add_to_photos, size: 14),
            tooltip: 'Insert into canvas',
            onPressed: () => _insertPreset(ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 14, color: Colors.grey.shade400),
            tooltip: 'Delete',
            onPressed: () =>
                ref.read(libraryProvider.notifier).deletePreset(preset.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  void _insertPreset(WidgetRef ref) {
    for (final json in preset.elementsJson) {
      try {
        final element = CanvasElement.fromJson(json);
        ref.read(canvasProvider.notifier).mergeRemoteElement(element);
      } catch (e) {
        debugPrint('Failed to insert preset element: $e');
      }
    }
  }
}
