import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class ResizablePanel extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final bool isLeft;

  const ResizablePanel({
    super.key,
    required this.child,
    required this.initialWidth,
    this.minWidth = AppConstants.minPanelWidth,
    this.maxWidth = AppConstants.maxPanelWidth,
    this.isLeft = true,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.isLeft) _buildHandle(),
        SizedBox(
          width: _width,
          child: widget.child,
        ),
        if (widget.isLeft) _buildHandle(),
      ],
    );
  }

  Widget _buildHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            if (widget.isLeft) {
              _width += details.delta.dx;
            } else {
              _width -= details.delta.dx;
            }
            _width = _width.clamp(widget.minWidth, widget.maxWidth);
          });
        },
        child: Container(
          width: 4,
          color: Colors.grey.shade400,
          child: Center(
            child: Container(
              width: 2,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
