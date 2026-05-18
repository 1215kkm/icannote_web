import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import '../models/canvas_element.dart';
import '../models/lecture.dart';

/// Service for exporting canvas content as PDF, Image, and printing.
class CanvasExportService {
  /// Render canvas elements to a ui.Image.
  static Future<ui.Image> renderCanvasToImage({
    required List<CanvasElement> elements,
    required double width,
    required double height,
    Color backgroundColor = Colors.white,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = backgroundColor,
    );

    // Draw all elements
    final size = Size(width, height);
    for (final element in elements) {
      if (!element.isDeleted && element is! StickerElement) {
        element.paint(canvas, size);
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }

  /// Convert ui.Image to PNG bytes.
  static Future<Uint8List?> imageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Export current canvas page as PNG image.
  static Future<bool> exportAsImage({
    required List<CanvasElement> elements,
    required double width,
    required double height,
    Color backgroundColor = Colors.white,
    String fileName = 'canvas_export.png',
  }) async {
    try {
      final image = await renderCanvasToImage(
        elements: elements,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
      );
      final bytes = await imageToBytes(image);
      if (bytes == null) return false;

      await FilePicker.platform.saveFile(
        dialogTitle: 'Save as Image',
        fileName: fileName,
        bytes: bytes,
      );
      return true;
    } catch (e) {
      debugPrint('Error exporting image: $e');
      return false;
    }
  }

  /// Export lecture as PDF (all pages).
  static Future<bool> exportAsPdf({
    required Lecture lecture,
    required List<CanvasElement> currentPageElements,
    required int currentPageIndex,
    String? fileName,
  }) async {
    try {
      final pdfBytes = await _buildPdf(
        lecture: lecture,
        currentPageElements: currentPageElements,
        currentPageIndex: currentPageIndex,
      );

      await FilePicker.platform.saveFile(
        dialogTitle: 'Save as PDF',
        fileName: fileName ?? '${lecture.title}.pdf',
        bytes: pdfBytes,
      );
      return true;
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      return false;
    }
  }

  /// Print lecture pages.
  static Future<void> printLecture({
    required Lecture lecture,
    required List<CanvasElement> currentPageElements,
    required int currentPageIndex,
  }) async {
    try {
      final pdfBytes = await _buildPdf(
        lecture: lecture,
        currentPageElements: currentPageElements,
        currentPageIndex: currentPageIndex,
      );

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: lecture.title,
      );
    } catch (e) {
      debugPrint('Error printing: $e');
    }
  }

  /// Build a PDF document from all lecture pages.
  static Future<Uint8List> _buildPdf({
    required Lecture lecture,
    required List<CanvasElement> currentPageElements,
    required int currentPageIndex,
  }) async {
    final pdf = pw.Document();

    for (int i = 0; i < lecture.pages.length; i++) {
      final page = lecture.pages[i];
      // Use current canvas elements for the active page
      final elements =
          i == currentPageIndex ? currentPageElements : page.visibleElements;

      // Render page to image
      final image = await renderCanvasToImage(
        elements: elements,
        width: lecture.pageWidth,
        height: lecture.pageHeight,
        backgroundColor: page.backgroundColor,
      );
      final bytes = await imageToBytes(image);
      if (bytes == null) continue;

      final pdfImage = pw.MemoryImage(bytes);

      // Determine orientation based on page dimensions
      final isLandscape = lecture.pageWidth > lecture.pageHeight;

      pdf.addPage(
        pw.Page(
          pageFormat: isLandscape
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4.portrait,
          build: (context) {
            return pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Capture the visible canvas area using a RepaintBoundary key.
  static Future<Uint8List?> captureScreenFromKey(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      return await imageToBytes(image);
    } catch (e) {
      debugPrint('Error capturing screen: $e');
      return null;
    }
  }
}
