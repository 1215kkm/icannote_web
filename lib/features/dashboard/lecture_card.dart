import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class LectureCard extends StatelessWidget {
  final String title;
  final int pageCount;
  final DateTime lastModified;
  final VoidCallback onTap;

  const LectureCard({
    super.key,
    required this.title,
    required this.pageCount,
    required this.lastModified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
          border: Border.all(
            color: AppColors.panelBorder,
            width: AppDimensions.borderWidthThin,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppDimensions.shadowBlurSM,
              offset: const Offset(0, AppDimensions.shadowOffsetY),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.canvasBackground,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSM),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeLG,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            // Info
            Text(
              '$pageCount pages',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeSM,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              _formatDate(lastModified),
              style: TextStyle(
                fontSize: AppDimensions.fontSizeSM,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
