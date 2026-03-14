import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../models/stroke.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../canvas/widgets/color_picker.dart';
import '../canvas/widgets/stroke_width_slider.dart';

class RightToolbar extends ConsumerWidget {
  const RightToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Container(
      width: AppDimensions.rightToolbarWidth,
      color: AppColors.toolbarBackground,
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
              ),
              _ToolButton(
                icon: Icons.gesture,
                tool: DrawingTool.pen,
                tooltip: 'Free Draw',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.pen),
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
              ),
              _ToolButton(
                icon: Icons.timeline,
                tool: DrawingTool.curve,
                tooltip: 'Curve',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.curve),
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
              ),
              _ToolButton(
                icon: Icons.circle_outlined,
                tool: DrawingTool.circle,
                tooltip: 'Circle',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.circle),
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
              ),
              _ToolButton(
                icon: Icons.change_history,
                tool: DrawingTool.triangle,
                tooltip: 'Triangle',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.triangle),
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
              ),
              _ToolButton(
                icon: Icons.auto_fix_high,
                tool: DrawingTool.autoShape,
                tooltip: 'Auto Shape',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.autoShape),
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
              ),
              _ToolButton(
                icon: Icons.rotate_right,
                tool: DrawingTool.rotation,
                tooltip: 'Rotate',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.rotation),
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
              ),
              _ToolButton(
                icon: Icons.pan_tool,
                tool: DrawingTool.pan,
                tooltip: 'Pan',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.pan),
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
              ),
              _ToolButton(
                icon: Icons.text_fields,
                tool: DrawingTool.none,
                tooltip: 'Text Options',
                currentTool: DrawingTool.none, // Never highlighted
                onTap: () {},
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
              ),
              _ToolButton(
                icon: Icons.highlight,
                tool: DrawingTool.highlighter,
                tooltip: 'Highlighter',
                currentTool: canvasState.currentTool,
                onTap: () => ref.read(canvasProvider.notifier).setTool(DrawingTool.highlighter),
              ),
            ],
          ),
          const Spacer(),
          // Stroke width display
          StrokeWidthDisplay(
            width: canvasState.strokeWidth,
            onChanged: (w) =>
                ref.read(canvasProvider.notifier).setStrokeWidth(w),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          // Color palette
          CompactColorPicker(
            selectedColor: canvasState.currentColor,
            onColorSelected: (c) =>
                ref.read(canvasProvider.notifier).setColor(c),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
        ],
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

  const _ToolButton({
    required this.icon,
    required this.tool,
    required this.tooltip,
    required this.currentTool,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentTool == tool;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: AppDimensions.toolButtonSize,
          height: AppDimensions.toolButtonSize,
          margin: const EdgeInsets.all(AppDimensions.toolButtonMargin),
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
            size: AppDimensions.iconSizeSM,
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
