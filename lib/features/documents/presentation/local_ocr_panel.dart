import 'package:flutter/material.dart';

import '../application/ocr/ocr_models.dart';

/// Reusable progress, review, and failure UI. The caller owns controller
/// actions so this component never receives a document path or raw file.
class LocalOcrPanel extends StatelessWidget {
  const LocalOcrPanel({
    super.key,
    required this.state,
    required this.onAccept,
    required this.onRetry,
    required this.onDiscard,
  });

  final LocalOcrState state;
  final VoidCallback onAccept;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) => switch (state) {
    LocalOcrIdle() => const SizedBox.shrink(),
    LocalOcrRunning() => Semantics(
      liveRegion: true,
      label: 'Local OCR in progress / লোকাল OCR চলছে',
      child: const ListTile(
        leading: CircularProgressIndicator(),
        title: Text(
          'Recognizing text locally / ডিভাইসেই লেখা শনাক্ত করা হচ্ছে',
        ),
        subtitle: Text(
          'The image is never uploaded / ছবিটি কখনো আপলোড করা হয় না',
        ),
      ),
    ),
    LocalOcrReview(:final recognition) => _Review(
      recognition: recognition,
      onAccept: onAccept,
      onDiscard: onDiscard,
    ),
    LocalOcrSuccess() => Semantics(
      liveRegion: true,
      child: ListTile(
        leading: Icon(Icons.check_circle_outline),
        title: Text('Recognized text saved / শনাক্ত করা লেখা সংরক্ষিত হয়েছে'),
      ),
    ),
    LocalOcrFailed(:final message) => Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('OCR could not finish / OCR সম্পন্ন করা যায়নি'),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again / আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      ),
    ),
  };
}

class _Review extends StatelessWidget {
  const _Review({
    required this.recognition,
    required this.onAccept,
    required this.onDiscard,
  });
  final OcrRecognition recognition;
  final VoidCallback onAccept;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review recognized text / শনাক্ত করা লেখা পর্যালোচনা করুন',
          ),
          const SizedBox(height: 8),
          const Text(
            'Save only if it is correct. It will not overwrite your fields. / সঠিক হলে তবেই সংরক্ষণ করুন। এটি আপনার তথ্য বদলাবে না।',
          ),
          if (recognition.wasTruncated) ...[
            const SizedBox(height: 8),
            const Text(
              'Long result shortened for safety / নিরাপত্তার জন্য দীর্ঘ ফল ছোট করা হয়েছে',
            ),
          ],
          const SizedBox(height: 12),
          SelectableText(recognition.text),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: onAccept,
                child: const Text('Save recognized text / লেখা সংরক্ষণ করুন'),
              ),
              OutlinedButton(
                onPressed: onDiscard,
                child: const Text('Discard / বাতিল করুন'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
