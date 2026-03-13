import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';

class StrokeWidthDisplay extends StatelessWidget {
  final double width;
  final ValueChanged<double> onChanged;

  const StrokeWidthDisplay({
    super.key,
    required this.width,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWidthPicker(context),
      child: Container(
        width: 44,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Center(
          child: Text(
            width.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showWidthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _StrokeWidthDialog(
        initialWidth: width,
        onChanged: onChanged,
      ),
    );
  }
}

class _StrokeWidthDialog extends StatefulWidget {
  final double initialWidth;
  final ValueChanged<double> onChanged;

  const _StrokeWidthDialog({
    required this.initialWidth,
    required this.onChanged,
  });

  @override
  State<_StrokeWidthDialog> createState() => _StrokeWidthDialogState();
}

class _StrokeWidthDialogState extends State<_StrokeWidthDialog> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stroke Width'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Container(
                height: _width,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(_width / 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${_width.toInt()}'),
              Expanded(
                child: Slider(
                  value: _width,
                  min: AppConstants.minStrokeWidth,
                  max: AppConstants.maxStrokeWidth,
                  divisions: 29,
                  onChanged: (v) {
                    setState(() => _width = v);
                    widget.onChanged(v);
                  },
                ),
              ),
            ],
          ),
          // Quick presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1.0, 3.0, 5.0, 10.0, 20.0].map((w) {
              return GestureDetector(
                onTap: () {
                  setState(() => _width = w);
                  widget.onChanged(w);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _width == w
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: _width == w ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Container(
                      width: w.clamp(2, 20),
                      height: w.clamp(2, 20),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
