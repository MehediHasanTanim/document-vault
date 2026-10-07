import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

import '../../../core/errors/app_failure.dart';
import '../application/ocr/ocr_models.dart';

/// Android/iOS-only, fully local Tesseract adapter. The app bundles `eng` and
/// `ben` trained data, so this path never downloads a model or uploads an image.
class TesseractLocalOcrEngine implements LocalOcrEngine {
  const TesseractLocalOcrEngine();

  @override
  Future<String> recognizeImage(
    File privateImage, {
    required OcrLanguage language,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      throw const OcrFailure(
        'Local OCR is available on Android and iOS only. / লোকাল OCR শুধু Android ও iOS-এ পাওয়া যায়।',
      );
    }
    if (!await privateImage.exists()) {
      throw const OcrFailure(
        'The image is no longer available for local OCR. / লোকাল OCR-এর ছবিটি আর পাওয়া যাচ্ছে না।',
      );
    }
    try {
      return await FlutterTesseractOcr.extractText(
        privateImage.path,
        language: language.tesseractCode,
        args: const {'psm': '6', 'preserve_interword_spaces': '1'},
      );
    } on Object catch (error) {
      throw OcrFailure(
        'Text could not be recognized on this device. / এই ডিভাইসে লেখা শনাক্ত করা যায়নি।',
        cause: error,
      );
    }
  }
}
