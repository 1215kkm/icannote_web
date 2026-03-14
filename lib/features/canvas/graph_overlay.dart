import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Type of mathematical function to plot.
enum GraphFunction {
  linear,
  quadratic,
  cubic,
  sine,
  cosine,
  tangent,
  absolute,
  squareRoot,
}

/// State for the graph tool overlay.
class GraphState {
  final bool isVisible;
  final Offset origin; // center of coordinate system on canvas
  final double scale; // pixels per unit
  final GraphFunction? activeFunction;
  final double paramA;
  final double paramB;
  final double paramC;
  final bool showGrid;
  final bool showAxes;

  const GraphState({
    this.isVisible = false,
    this.origin = const Offset(400, 400),
    this.scale = 40.0,
    this.activeFunction,
    this.paramA = 1.0,
    this.paramB = 0.0,
    this.paramC = 0.0,
    this.showGrid = true,
    this.showAxes = true,
  });

  GraphState copyWith({
    bool? isVisible,
    Offset? origin,
    double? scale,
    GraphFunction? activeFunction,
    double? paramA,
    double? paramB,
    double? paramC,
    bool? showGrid,
    bool? showAxes,
  }) {
    return GraphState(
      isVisible: isVisible ?? this.isVisible,
      origin: origin ?? this.origin,
      scale: scale ?? this.scale,
      activeFunction: activeFunction ?? this.activeFunction,
      paramA: paramA ?? this.paramA,
      paramB: paramB ?? this.paramB,
      paramC: paramC ?? this.paramC,
      showGrid: showGrid ?? this.showGrid,
      showAxes: showAxes ?? this.showAxes,
    );
  }
}

class GraphNotifier extends StateNotifier<GraphState> {
  GraphNotifier() : super(const GraphState());

  void toggle() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  void show() => state = state.copyWith(isVisible: true);
  void hide() => state = state.copyWith(isVisible: false);

  void setOrigin(Offset origin) => state = state.copyWith(origin: origin);
  void setScale(double scale) =>
      state = state.copyWith(scale: scale.clamp(10.0, 200.0));

  void setFunction(GraphFunction? fn) =>
      state = state.copyWith(activeFunction: fn);

  void setParams({double? a, double? b, double? c}) {
    state = state.copyWith(
      paramA: a ?? state.paramA,
      paramB: b ?? state.paramB,
      paramC: c ?? state.paramC,
    );
  }

  void toggleGrid() => state = state.copyWith(showGrid: !state.showGrid);
  void toggleAxes() => state = state.copyWith(showAxes: !state.showAxes);
}

final graphProvider =
    StateNotifierProvider<GraphNotifier, GraphState>((ref) => GraphNotifier());

/// Overlay widget that draws coordinate grid and function plots.
class GraphOverlay extends ConsumerWidget {
  const GraphOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphState = ref.watch(graphProvider);

    if (!graphState.isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // Grid and function plot
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GraphPainter(state: graphState),
            ),
          ),
        ),
        // Control panel
        Positioned(
          top: AppDimensions.spacingMD,
          left: AppDimensions.spacingMD,
          child: _GraphControlPanel(),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final GraphState state;

  _GraphPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = state.origin;
    final scale = state.scale;

    // Draw grid
    if (state.showGrid) {
      _drawGrid(canvas, size, origin, scale);
    }

    // Draw axes
    if (state.showAxes) {
      _drawAxes(canvas, size, origin, scale);
    }

    // Draw function
    if (state.activeFunction != null) {
      _drawFunction(canvas, size, origin, scale);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Offset origin, double scale) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    // Vertical lines
    double x = origin.dx % scale;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      x += scale;
    }

    // Horizontal lines
    double y = origin.dy % scale;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      y += scale;
    }
  }

  void _drawAxes(Canvas canvas, Size size, Offset origin, double scale) {
    final axisPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;

    // X axis
    canvas.drawLine(
      Offset(0, origin.dy),
      Offset(size.width, origin.dy),
      axisPaint,
    );

    // Y axis
    canvas.drawLine(
      Offset(origin.dx, 0),
      Offset(origin.dx, size.height),
      axisPaint,
    );

    // Tick marks and labels
    final tickPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.black.withValues(alpha: 0.5),
      fontSize: 9,
    );

    // X axis ticks
    for (double px = origin.dx + scale;
        px < size.width;
        px += scale) {
      canvas.drawLine(
          Offset(px, origin.dy - 3), Offset(px, origin.dy + 3), tickPaint);
      final value = ((px - origin.dx) / scale).round();
      _drawText(canvas, '$value', Offset(px - 4, origin.dy + 5), textStyle);
    }
    for (double px = origin.dx - scale; px > 0; px -= scale) {
      canvas.drawLine(
          Offset(px, origin.dy - 3), Offset(px, origin.dy + 3), tickPaint);
      final value = ((px - origin.dx) / scale).round();
      _drawText(canvas, '$value', Offset(px - 6, origin.dy + 5), textStyle);
    }

    // Y axis ticks
    for (double py = origin.dy - scale; py > 0; py -= scale) {
      canvas.drawLine(
          Offset(origin.dx - 3, py), Offset(origin.dx + 3, py), tickPaint);
      final value = ((origin.dy - py) / scale).round();
      _drawText(
          canvas, '$value', Offset(origin.dx + 5, py - 5), textStyle);
    }
    for (double py = origin.dy + scale;
        py < size.height;
        py += scale) {
      canvas.drawLine(
          Offset(origin.dx - 3, py), Offset(origin.dx + 3, py), tickPaint);
      final value = ((origin.dy - py) / scale).round();
      _drawText(
          canvas, '$value', Offset(origin.dx + 5, py - 5), textStyle);
    }
  }

  void _drawText(
      Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  void _drawFunction(Canvas canvas, Size size, Offset origin, double scale) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool started = false;

    for (double px = 0; px < size.width; px += 1.0) {
      final x = (px - origin.dx) / scale;
      final y = _evaluate(x);

      if (y.isNaN || y.isInfinite) {
        started = false;
        continue;
      }

      final py = origin.dy - y * scale;

      if (py < -1000 || py > size.height + 1000) {
        started = false;
        continue;
      }

      if (!started) {
        path.moveTo(px, py);
        started = true;
      } else {
        path.lineTo(px, py);
      }
    }

    canvas.drawPath(path, paint);
  }

  double _evaluate(double x) {
    final a = state.paramA;
    final b = state.paramB;
    final c = state.paramC;

    switch (state.activeFunction!) {
      case GraphFunction.linear:
        return a * x + b;
      case GraphFunction.quadratic:
        return a * x * x + b * x + c;
      case GraphFunction.cubic:
        return a * x * x * x + b * x + c;
      case GraphFunction.sine:
        return a * math.sin(b != 0 ? b * x : x) + c;
      case GraphFunction.cosine:
        return a * math.cos(b != 0 ? b * x : x) + c;
      case GraphFunction.tangent:
        return a * math.tan(b != 0 ? b * x : x) + c;
      case GraphFunction.absolute:
        return a * x.abs() + b * x + c;
      case GraphFunction.squareRoot:
        return x >= 0 ? a * math.sqrt(x) + c : double.nan;
    }
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) =>
      state != oldDelegate.state;
}

class _GraphControlPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphState = ref.watch(graphProvider);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: AppDimensions.shadowBlurMD,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.show_chart, size: 16),
              const SizedBox(width: AppDimensions.spacingSM),
              const Text(
                'Graph Tool',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontSizeMD,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => ref.read(graphProvider.notifier).hide(),
                child: const Icon(Icons.close, size: 16),
              ),
            ],
          ),
          const Divider(),

          // Function selector
          const Text('Function:', style: TextStyle(fontSize: 11)),
          const SizedBox(height: AppDimensions.spacingSM),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: GraphFunction.values.map((fn) {
              final isSelected = graphState.activeFunction == fn;
              return InkWell(
                onTap: () => ref.read(graphProvider.notifier).setFunction(fn),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSM),
                  ),
                  child: Text(
                    _fnLabel(fn),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.spacingMD),

          // Parameters
          _ParamSlider(
            label: 'a',
            value: graphState.paramA,
            onChanged: (v) =>
                ref.read(graphProvider.notifier).setParams(a: v),
          ),
          _ParamSlider(
            label: 'b',
            value: graphState.paramB,
            onChanged: (v) =>
                ref.read(graphProvider.notifier).setParams(b: v),
          ),
          _ParamSlider(
            label: 'c',
            value: graphState.paramC,
            onChanged: (v) =>
                ref.read(graphProvider.notifier).setParams(c: v),
          ),

          const SizedBox(height: AppDimensions.spacingMD),

          // Options
          Row(
            children: [
              Checkbox(
                value: graphState.showGrid,
                onChanged: (_) =>
                    ref.read(graphProvider.notifier).toggleGrid(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const Text('Grid', style: TextStyle(fontSize: 11)),
              const SizedBox(width: AppDimensions.spacingLG),
              Checkbox(
                value: graphState.showAxes,
                onChanged: (_) =>
                    ref.read(graphProvider.notifier).toggleAxes(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const Text('Axes', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _fnLabel(GraphFunction fn) {
    switch (fn) {
      case GraphFunction.linear:
        return 'y=ax+b';
      case GraphFunction.quadratic:
        return 'y=ax²+bx+c';
      case GraphFunction.cubic:
        return 'y=ax³+bx+c';
      case GraphFunction.sine:
        return 'y=a·sin(bx)+c';
      case GraphFunction.cosine:
        return 'y=a·cos(bx)+c';
      case GraphFunction.tangent:
        return 'y=a·tan(bx)+c';
      case GraphFunction.absolute:
        return 'y=a|x|+bx+c';
      case GraphFunction.squareRoot:
        return 'y=a√x+c';
    }
  }
}

class _ParamSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _ParamSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: value.clamp(-5.0, 5.0),
              min: -5.0,
              max: 5.0,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
