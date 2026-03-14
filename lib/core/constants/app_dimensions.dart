/// Centralized UI dimension tokens for the ICanNote app.
///
/// All hardcoded sizes, spacing, border values etc. are collected here
/// so that changing a value in this file applies everywhere immediately.
class AppDimensions {
  AppDimensions._();

  // ===== Font Sizes =====
  static const double fontSizeXS = 9.0; // page numbers, tiny labels
  static const double fontSizeSM = 11.0; // toolbar labels, info text
  static const double fontSizeMD = 12.0; // menu items, subtitles
  static const double fontSizeLG = 16.0; // titles, text input default
  static const double fontSizeXL = 18.0; // reserved

  // ===== Icon Sizes =====
  static const double iconSizeSM = 16.0; // right toolbar tool icons
  static const double iconSizeMD = 18.0; // bottom toolbar icons
  static const double iconSizeLG = 48.0; // home screen card icons

  // ===== Toolbar Dimensions =====
  static const double topMenuBarHeight = 32.0;
  static const double bottomToolbarHeight = 36.0;
  static const double rightToolbarWidth = 52.0;

  // ===== Button Sizes =====
  static const double toolButtonSize = 24.0; // right toolbar buttons
  static const double toolButtonMargin = 1.0;
  static const double actionButtonSize = 32.0; // bottom toolbar action btns
  static const double actionButtonMarginH = 1.0;
  static const double bottomButtonMinSize = 28.0;

  // ===== Spacing =====
  static const double spacingXS = 2.0;
  static const double spacingSM = 4.0;
  static const double spacingMD = 8.0;
  static const double spacingLG = 12.0;
  static const double spacingXL = 16.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // ===== Border Radius =====
  static const double borderRadiusXS = 1.0;
  static const double borderRadiusSM = 4.0;
  static const double borderRadiusMD = 12.0;
  static const double borderRadiusLG = 16.0;

  // ===== Border Width =====
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthThick = 2.0;

  // ===== Shadows =====
  static const double shadowBlurSM = 4.0;
  static const double shadowBlurMD = 10.0;
  static const double shadowBlurLG = 12.0;
  static const double shadowOffsetY = 2.0;
  static const double shadowOffsetYLG = 4.0;

  // ===== Home Screen =====
  static const double homeCardWidth = 180.0;
  static const double homeCardPadding = 24.0;
  static const double homeCardGap = 32.0;
  static const double homeIconContainerSize = 100.0;

  // ===== Text Input =====
  static const double textFieldWidth = 80.0;
  static const double textInputMinWidth = 100.0;
  static const double textInputMaxWidth = 300.0;
  static const double textInputPadding = 8.0;

  // ===== Canvas =====
  static const double canvasMinScale = 0.25;
  static const double canvasMaxScale = 5.0;
  static const double canvasBoundaryMargin = 200.0;

  // ===== Resize Handle =====
  static const double resizeHandleWidth = 4.0;
  static const double resizeIndicatorHeight = 30.0;

  // ===== Menu Bar Item =====
  static const double menuItemPaddingH = 12.0;
  static const double menuItemPaddingV = 6.0;

  // ===== Divider =====
  static const double dividerHeight = 1.0;
  static const double dividerMarginH = 6.0;
  static const double dividerMarginV = 2.0;

  // ===== Page Thumbnail =====
  static const double thumbnailMarginV = 2.0;
  static const double thumbnailMarginH = 4.0;
}
