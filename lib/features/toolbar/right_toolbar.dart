import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../models/stroke.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../canvas/widgets/color_picker.dart';
import '../canvas/widgets/stroke_width_slider.dart';

class RightToolbar extends ConsumerWidget {
  final double width;
  const RightToolbar({super.key, this.width = AppDimensions.rightToolbarWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    // Scale tool sizes based on panel width
    final scale = (width / AppDimensions.rightToolbarWidth).clamp(1.0, 3.0);
    final toolSize = (AppDimensions.toolButtonSize * scale).clamp(24.0, 64.0);
    final iconSize = (AppDimensions.iconSizeSM * scale).clamp(16.0, 40.0);
    final toolMargin = (AppDimensions.toolButtonMargin * scale).clamp(1.0, 4.0);

    return Container(
      width: width,
      color: AppColors.toolbarBackground,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacingSM),
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.radio_button_unchecked,
                  tool: DrawingTool.laserPointer,
                  tooltip: 'Laser Pointer',
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
                  tooltip: 'Free Draw',
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
                  tooltip: 'Line',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.line),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.timeline,
                  tool: DrawingTool.curve,
                  tooltip: 'Curve',
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
                  tooltip: 'Rectangle',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.rectangle),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.circle_outlined,
                  tool: DrawingTool.circle,
                  tooltip: 'Circle',
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
                  tooltip: 'Polygon',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.polygon),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.change_history,
                  tool: DrawingTool.triangle,
                  tooltip: 'Triangle',
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
                  tooltip: 'Sticker',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.sticker),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.auto_fix_high,
                  tool: DrawingTool.autoShape,
                  tooltip: 'Auto Shape',
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
                  tooltip: 'Select',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.selection),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.rotate_right,
                  tool: DrawingTool.rotation,
                  tooltip: 'Rotate',
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
                  tooltip: 'Detail Eraser',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.eraser),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.pan_tool,
                  tool: DrawingTool.pan,
                  tooltip: 'Pan',
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
                  tooltip: 'Text',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.text),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.text_fields,
                  tool: DrawingTool.none,
                  tooltip: 'Text Options',
                  currentTool: DrawingTool.none,
                  onTap: () {},
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
              ],
            ),
            _divider(),
            // Pen & Highlighter
            _ToolGroup(
              children: [
                _ToolButton(
                  icon: Icons.edit,
                  tool: DrawingTool.pen,
                  tooltip: 'Pen',
                  currentTool: canvasState.currentTool,
                  onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.pen),
                  size: toolSize,
                  iconSize: iconSize,
                  margin: toolMargin,
                ),
                _ToolButton(
                  icon: Icons.highlight,
                  tool: DrawingTool.highlighter,
                  tooltip: 'Highlighter',
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
