import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PageThumbnail extends StatelessWidget {
  final int pageIndex;
  final bool isSelected;
  final Color backgroundColor;
  final VoidCallback onTap;

  const PageThumbnail({
    super.key,
    required this.pageIndex,
    required this.isSelected,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.panelBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: AspectRatio(
          aspectRatio: 1112 / 770,
          child: Stack(
            children: [
              // Page content would be rendered here as thumbnail
              Positioned(
                bottom: 2,
                right: 4,
                child: Text(
                  '${pageIndex + 1}',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
