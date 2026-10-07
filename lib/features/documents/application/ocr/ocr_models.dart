import 'dart:io';

enum OcrLanguage {
  english('eng'),
  bengali('ben'),
  bengaliAndEnglish('ben+eng');

  const OcrLanguage(this.tesseractCode);
  final String tesseractCode;
}

enum OcrProgressStage {
  preparing,
  recognizing,
  review,
  saving,
  complete,
  failed,
}

class OcrProgress {
  const OcrProgress(this.stage);
  final OcrProgressStage stage;
}

/// OCR output is intentionally transient until the user explicitly accepts it.
class OcrRecognition {
  const OcrRecognition({
    required this.text,
    required this.language,
    required this.wasTruncated,
  });

  static const maxCharacters = 50000;
  final String text;
  final OcrLanguage language;
  final bool wasTruncated;
  bool get hasText => text.trim().isNotEmpty;

  factory OcrRecognition.fromEngineText(
    String value, {
    required OcrLanguage language,
  }) {
    final normalized = value.replaceAll('\u0000', '').trim();
    final truncated = normalized.length > maxCharacters;
    return OcrRecognition(
      text: truncated ? normalized.substring(0, maxCharacters) : normalized,
      language: language,
      wasTruncated: truncated,
    );
  }
}

/// The engine receives only an app-private, short-lived image file.
abstract interface class LocalOcrEngine {
  Future<String> recognizeImage(
    File privateImage, {
    required OcrLanguage language,
  });
}

sealed class LocalOcrState {
  const LocalOcrState();
}

class LocalOcrIdle extends LocalOcrState {
  const LocalOcrIdle();
}

class LocalOcrRunning extends LocalOcrState {
  const LocalOcrRunning(this.progress);
  final OcrProgress progress;
}

class LocalOcrReview extends LocalOcrState {
  const LocalOcrReview(this.recognition);
  final OcrRecognition recognition;
}

class LocalOcrSuccess extends LocalOcrState {
  const LocalOcrSuccess();
}

class LocalOcrFailed extends LocalOcrState {
  const LocalOcrFailed(this.message);
  final String message;
}
