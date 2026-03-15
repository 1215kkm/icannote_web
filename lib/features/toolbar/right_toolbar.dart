import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/stroke.dart';
import '../../models/canvas_element.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/l10n/app_localizations.dart';
import '../canvas/widgets/color_picker.dart';
import '../canvas/widgets/stroke_width_slider.dart';

/// Provider for text options state
final textOptionsProvider = StateNotifierProvider<TextOptionsNotifier, TextOptionsState>((ref) {
  return TextOptionsNotifier();
});

class TextOptionsState {
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool showPanel;

  const TextOptionsState({
    this.fontSize = 16,
    this.isBold = false,
    this.isItalic = false,
    this.showPanel = false,
  });

  TextOptionsState copyWith({
    double? fontSize,
    bool? isBold,
    bool? isItalic,
    bool? showPanel,
  }) {
    return TextOptionsState(
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      showPanel: showPanel ?? this.showPanel,
    );
  }
}

class TextOptionsNotifier extends StateNotifier<TextOptionsState> {
  TextOptionsNotifier() : super(const TextOptionsState());

  void setFontSize(double size) => state = state.copyWith(fontSize: size.clamp(8, 72));
  void toggleBold() => state = state.copyWith(isBold: !state.isBold);
  void toggleItalic() => state = state.copyWith(isItalic: !state.isItalic);
  void togglePanel() => state = state.copyWith(showPanel: !state.showPanel);
  void hidePanel() => state = state.copyWith(showPanel: false);
}

class RightToolbar extends ConsumerWidget {
  final double width;
  const RightToolbar({super.key, this.width = AppDimensions.rightToolbarWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    final textOptions = ref.watch(textOptionsProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);
    // Scale tool sizes based on panel width
    final scale = (width / AppDimensions.rightToolbarWidth).clamp(1.0, 3.0);
    final toolSize = (AppDimensions.toolButtonSize * scale).clamp(24.0, 64.0);
    final iconSize = (AppDimensions.iconSizeSM * scale).clamp(16.0, 40.0);
    final toolMargin = (AppDimensions.toolButtonMargin * scale).clamp(1.0, 4.0);

    return Container(
      width: width,
      color: AppColors.toolbarBackground,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingSM),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.radio_button_unchecked,
                  tool: DrawingTool.laserPointer,
                  tooltip: l10n.laserPointer,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.laserPointer),
                  isHighlighted: true,
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.gesture,
                  tool: DrawingTool.pen,
                  tooltip: l10n.freeDraw,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.pen),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _divider(),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.show_chart,
                  tool: DrawingTool.line,
                  tooltip: l10n.line,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.line),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.timeline,
                  tool: DrawingTool.curve,
                  tooltip: l10n.curve,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.curve),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.crop_square,
                  tool: DrawingTool.rectangle,
                  tooltip: l10n.rectangle,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.rectangle),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.circle_outlined,
                  tool: DrawingTool.circle,
                  tooltip: l10n.circle,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.circle),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.hexagon_outlined,
                  tool: DrawingTool.polygon,
                  tooltip: l10n.polygon,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.polygon),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.change_history,
                  tool: DrawingTool.triangle,
                  tooltip: l10n.triangle,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.triangle),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _divider(),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.note,
                  tool: DrawingTool.sticker,
                  tooltip: l10n.sticker,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.sticker),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.auto_fix_high,
                  tool: DrawingTool.autoShape,
                  tooltip: l10n.autoShape,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.autoShape),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.select_all,
                  tool: DrawingTool.selection,
                  tooltip: l10n.select,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.selection),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.rotate_right,
                  tool: DrawingTool.rotation,
                  tooltip: l10n.rotate,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.rotation),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.auto_fix_normal,
                  tool: DrawingTool.eraser,
                  tooltip: l10n.detailEraser,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.eraser),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.pan_tool,
                  tool: DrawingTool.pan,
                  tooltip: l10n.pan,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.pan),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _divider(),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.title,
                  tool: DrawingTool.text,
                  tooltip: l10n.text,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.text),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.text_fields,
                  tool: DrawingTool.none,
                  tooltip: l10n.textOptions,
                  currentTool: textOptions.showPanel ? DrawingTool.text : DrawingTool.none,
                  onTap: () => ref.read(textOptionsProvider.notifier).togglePanel(),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            // Text Options Panel
            if (textOptions.showPanel)
              _TextOptionsPanel(ref: ref, textOptions: textOptions),
            _divider(),
            // Pen & Highlighter
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.edit,
                  tool: DrawingTool.pen,
                  tooltip: l10n.pen,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.pen),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.highlight,
                  tool: DrawingTool.highlighter,
                  tooltip: l10n.highlighter,
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.highlighter),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            // Color palette (right under pen/highlighter)
            CompactColorPicker(
              selectedColor: canvasState.currentColor,
              onColorSelected: (c) =>
                  ref.read(canvasProvider.notifier).setColor(c),
              width: width,
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            // Stroke width display
            StrokeWidthDisplay(
              width: canvasState.strokeWidth,
              onChanged: (w) =>
                  ref.read(canvasProvider.notifier).setStrokeWidth(w),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: AppDimensions.dividerHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.dividerMarginH,
          vertical: AppDimensions.dividerMarginV,
        ),
        color: AppColors.toolbarDivider,
      );
}

/// Text Options Panel widget
class _TextOptionsPanel extends StatelessWidget {
  final WidgetRef ref;
  final TextOptionsState textOptions;

  const _TextOptionsPanel({required this.ref, required this.textOptions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Font size
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(ref.read(settingsProvider).language.code == 'ko' ? '크기' : 'Size',
                style: const TextStyle(color: AppColors.toolbarIconDefault, fontSize: 11)),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                height: 24,
                child: TextField(
                  controller: TextEditingController(text: textOptions.fontSize.toInt().toString()),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.toolbarDivider),
                    ),
                  ),
                  onSubmitted: (value) {
                    final size = double.tryParse(value);
                    if (size != null) {
                      ref.read(textOptionsProvider.notifier).setFontSize(size);
                      _updateSelectedTextElement(ref);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Font size slider
          SizedBox(
            height: 20,
            child: SliderTheme(
              data: SliderThemeData(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.toolbarDivider,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: textOptions.fontSize,
                min: 8,
                max: 72,
                onChanged: (v) {
                  ref.read(textOptionsProvider.notifier).setFontSize(v);
                  _updateSelectedTextElement(ref);
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Bold & Italic toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ToggleButton(
                label: 'B',
                isActive: textOptions.isBold,
                fontWeight: FontWeight.bold,
                onTap: () {
                  ref.read(textOptionsProvider.notifier).toggleBold();
                  _updateSelectedTextElement(ref);
                },
              ),
              const SizedBox(width: 4),
              _ToggleButton(
                label: 'I',
                isActive: textOptions.isItalic,
                fontStyle: FontStyle.italic,
                onTap: () {
                  ref.read(textOptionsProvider.notifier).toggleItalic();
                  _updateSelectedTextElement(ref);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Update selected text element with current text options.
  void _updateSelectedTextElement(WidgetRef ref) {
    final canvasState = ref.read(canvasProvider);
    final selectedEl = canvasState.selectedElement;
    if (selectedEl is TextCanvasElement) {
      final textOpts = ref.read(textOptionsProvider);
      final updated = selectedEl.copyWith(
        fontSize: textOpts.fontSize,
        isBold: textOpts.isBold,
        isItalic: textOpts.isItalic,
      );
      final elements = [...canvasState.elements];
      final idx = elements.indexWhere((e) => e.id == selectedEl.id);
      if (idx != -1) {
        elements[idx] = updated;
        ref.read(canvasProvider.notifier).loadElements(elements);
        ref.read(lectureProvider.notifier).updateCurrentPageElements(elements);
      }
    }
  }
}

/// Toggle button for bold/italic.
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    this.fontWeight,
    this.fontStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isActive ? Border.all(color: AppColors.primary, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.toolbarIconDefault,
            fontSize: 14,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
          ),
        ),
      ),
    );
  }
}

class _ToolGroup extends StatelessWidget {
  final List<Widget> children;
  const _ToolGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final DrawingTool tool;
  final String tooltip;
  final DrawingTool currentTool;
  final VoidCallback onTap;
  final bool isHighlighted;
  final double size;
  final double iconSize;
  final double margin;

  const _ToolButton({
    required this.icon,
    required this.tool,
    required this.tooltip,
    required this.currentTool,
    required this.onTap,
    this.isHighlighted = false,
    this.size = AppDimensions.toolButtonSize,
    this.iconSize = AppDimensions.iconSizeSM,
    this.margin = AppDimensions.toolButtonMargin,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentTool == tool;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
            border: isActive
                ? Border.all(
                    color: AppColors.primary,
                    width: AppDimensions.borderWidthMedium,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: isActive
                ? AppColors.toolbarIconActive
                : isHighlighted
                    ? AppColors.accent
                    : AppColors.toolbarIconDefault,
          ),
        ),
      ),
    );
  }
}
