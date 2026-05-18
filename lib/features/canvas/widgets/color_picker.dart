import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CompactColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final double width;

  const CompactColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.width = 48,
  });

  @override
  Widget build(BuildContext context) {
    final availableWidth = width - 4; // padding
    // Calculate color swatch size based on available width
    // 3 columns by default, scale with width
    final cols = (availableWidth / 16).floor().clamp(3, 6);
    final swatchSize = ((availableWidth - (cols - 1)) / cols).clamp(10.0, 28.0);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        children: AppColors.defaultPalette.map((color) {
          final isSelected = selectedColor.toARGB32() == color.toARGB32();
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: swatchSize,
              height: swatchSize,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  width: isSelected ? 2 : 0.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({super.key, required this.initialColor});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  late int _r;
  late int _g;
  late int _b;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _syncRgbFrom(_selectedColor);
  }

  // Derive 0–255 channels from the 32-bit ARGB value (avoids the
  // float-vs-int ambiguity of Color.r/.g/.b across Flutter versions).
  void _syncRgbFrom(Color c) {
    final argb = c.toARGB32();
    _r = (argb >> 16) & 0xFF;
    _g = (argb >> 8) & 0xFF;
    _b = argb & 0xFF;
  }

  void _applyRgb() {
    setState(() {
      _selectedColor = Color.fromARGB(255, _r, _g, _b);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Color'),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...AppColors.defaultPalette.map((c) => _colorCircle(c)),
                  ..._extendedColors.map((c) => _colorCircle(c)),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _channelSlider('R', _r, Colors.red, (v) {
                _r = v;
                _applyRgb();
              }),
              _channelSlider('G', _g, Colors.green, (v) {
                _g = v;
                _applyRgb();
              }),
              _channelSlider('B', _b, Colors.blue, (v) {
                _b = v;
                _applyRgb();
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _channelSlider(
    String label,
    int value,
    Color accent,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(label,
              style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(activeTrackColor: accent, thumbColor: accent),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 255,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text('$value', textAlign: TextAlign.end),
        ),
      ],
    );
  }

  Widget _colorCircle(Color color) {
    final isSelected = _selectedColor.toARGB32() == color.toARGB32();
    return GestureDetector(
      onTap: () => setState(() {
        _selectedColor = color;
        _syncRgbFrom(color);
      }),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  static const List<Color> _extendedColors = [
    Color(0xFF333333),
    Color(0xFF666666),
    Color(0xFF999999),
    Color(0xFFCCCCCC),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFFA07A),
    Color(0xFFDDA0DD),
    Color(0xFF98D8C8),
    Color(0xFFF7DC6F),
  ];
}
