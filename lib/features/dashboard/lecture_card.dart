import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/l10n/app_localizations.dart';
import '../../features/canvas/canvas_painter.dart';
import '../../models/page_data.dart';

class LectureCard extends StatelessWidget {
  final String title;
  final int pageCount;
  final DateTime lastModified;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final PageData? firstPage;
  final double pageWidth;
  final double pageHeight;

  const LectureCard({
    super.key,
    required this.title,
    required this.pageCount,
    required this.lastModified,
    required this.onTap,
    required this.l10n,
    this.firstPage,
    required this.pageWidth,
    required this.pageHeight,
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
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSM),
                child: Container(
                  width: double.infinity,
                  color: firstPage?.backgroundColor ?? AppColors.canvasBackground,
                  child: firstPage == null
                      ? Center(
                          child: Icon(
                            Icons.description_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: pageWidth,
                            height: pageHeight,
                            child: CustomPaint(
                              painter: CanvasPainter(
                                elements: firstPage!.visibleElements,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
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
            Text(
              '$pageCount ${l10n.get('pages_suffix')}',
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
