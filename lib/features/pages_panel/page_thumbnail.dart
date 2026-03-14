import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';

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
        margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.thumbnailMarginV,
          horizontal: AppDimensions.thumbnailMarginH,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.panelBorder,
            width: isSelected
                ? AppDimensions.borderWidthThick
                : AppDimensions.borderWidthThin,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
          color: backgroundColor,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: AppDimensions.shadowBlurSM,
                  )
                ]
              : null,
        ),
        child: AspectRatio(
          aspectRatio:
              AppConstants.defaultPageWidth / AppConstants.defaultPageHeight,
          child: Stack(
            children: [
              // Page content would be rendered here as thumbnail
              Positioned(
                bottom: AppDimensions.spacingXS,
                right: AppDimensions.spacingSM,
                child: Text(
                  '${pageIndex + 1}',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeXS,
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
