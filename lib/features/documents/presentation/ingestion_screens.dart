import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../application/ingestion/ingestion_permissions.dart';
import '../application/ingestion/multi_page_capture_draft.dart';
import '../infrastructure/device_camera_capture.dart';

class AddDocumentMethodSheet extends StatelessWidget {
  const AddDocumentMethodSheet({
    required this.onScan,
    required this.onImportPhotos,
    required this.onImportFile,
    super.key,
  });
  final VoidCallback onScan;
  final VoidCallback onImportPhotos;
  final VoidCallback onImportFile;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Add Document / ডকুমেন্ট যোগ করুন',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _methodTile(
            icon: Icons.document_scanner_outlined,
            title: 'Scan with camera / ক্যামেরায় স্ক্যান',
            subtitle: 'Best for physical documents / কাগজের নথির জন্য',
            onTap: onScan,
          ),
          _methodTile(
            icon: Icons.photo_library_outlined,
            title: 'Import photos / ছবি আনুন',
            subtitle: 'Choose document images / নথির ছবি বেছে নিন',
            onTap: onImportPhotos,
          ),
          _methodTile(
            icon: Icons.upload_file_outlined,
            title: 'Import PDF or file / পিডিএফ বা ফাইল আনুন',
            subtitle:
                'Use your device file picker / ডিভাইস ফাইল পিকার ব্যবহার করুন',
            onTap: onImportFile,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / বাতিল'),
          ),
        ],
      ),
    ),
  );

  Widget _methodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    minVerticalPadding: 10,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

/// Camera content never enters the public gallery. The caller receives only a
/// temporary file and must stage it with [SecureImportService] on acceptance.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({
    required this.permissions,
    required this.camera,
    required this.onAccept,
    this.onGallery,
    this.existingPageCount = 0,
    super.key,
  });
  final IngestionPermissionService permissions;
  final DeviceCameraCapture camera;
  final ValueChanged<File> onAccept;
  final VoidCallback? onGallery;
  final int existingPageCount;

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  File? _captured;
  Object? _error;
  var _ready = false;
  var _flashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  Future<void> _open() async {
    try {
      await widget.permissions.ensureCamera();
      await widget.camera.open();
      if (mounted) setState(() => _ready = true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      widget.camera.dispose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: _error != null
          ? _CameraError(onClose: () => Navigator.pop(context), onRetry: _open)
          : !_ready
          ? const Center(child: CircularProgressIndicator())
          : _captured == null
          ? _preview()
          : _confirmation(),
    ),
  );

  Widget _preview() => Stack(
    fit: StackFit.expand,
    children: [
      CameraPreview(widget.camera.controller),
      Center(
        child: IgnorePointer(
          child: Container(
            width: 280,
            height: 390,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      Positioned(
        top: 8,
        left: 8,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close camera / ক্যামেরা বন্ধ করুন',
          color: Colors.white,
          icon: const Icon(Icons.close),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          onPressed: () async {
            final enabled = await widget.camera.toggleFlash();
            if (mounted) setState(() => _flashOn = enabled);
          },
          tooltip: 'Flash / ফ্ল্যাশ',
          color: Colors.white,
          icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
        ),
      ),
      Positioned(
        bottom: 24,
        left: 20,
        right: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: widget.onGallery,
              tooltip: 'Import photos / ছবি আনুন',
              color: Colors.white,
              icon: const Icon(Icons.photo_library_outlined),
            ),
            Semantics(
              button: true,
              label: 'Capture page / পৃষ্ঠা তুলুন',
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  onPressed: () async {
                    final file = await widget.camera.capture();
                    if (mounted) setState(() => _captured = file);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
            Chip(label: Text('${widget.existingPageCount + 1} page / পৃষ্ঠা')),
          ],
        ),
      ),
    ],
  );

  Widget _confirmation() => Column(
    children: [
      Expanded(
        child: Center(child: Image.file(_captured!, fit: BoxFit.contain)),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _captured = null),
                child: const Text('Retake / আবার তুলুন'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  widget.onAccept(_captured!);
                  Navigator.pop(context);
                },
                child: const Text('Use page / পৃষ্ঠা ব্যবহার করুন'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.onClose, required this.onRetry});
  final VoidCallback onClose;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            color: Colors.white,
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'Camera access is needed to scan.\nস্ক্যান করতে ক্যামেরা অনুমতি প্রয়োজন।',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try again / আবার চেষ্টা করুন'),
          ),
          TextButton(
            onPressed: onClose,
            child: const Text('Close / বন্ধ করুন'),
          ),
        ],
      ),
    ),
  );
}

/// A reviewed cropper can be injected without widening the secure import API.
class CropAdjustScreen extends StatefulWidget {
  const CropAdjustScreen({
    required this.file,
    required this.onUse,
    this.cropper,
    this.initialRotation = 0,
    super.key,
  });
  final File file;
  final ValueChanged<CapturePage> onUse;
  final DocumentCropper? cropper;
  final int initialRotation;

  @override
  State<CropAdjustScreen> createState() => _CropAdjustScreenState();
}

class _CropAdjustScreenState extends State<CropAdjustScreen> {
  late File _file;
  late int _rotation;
  @override
  void initState() {
    super.initState();
    _file = widget.file;
    _rotation = widget.initialRotation;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Adjust page / পৃষ্ঠা ঠিক করুন')),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: _rotation ~/ 90,
                child: Image.file(_file, fit: BoxFit.contain),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.cropper != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final cropped = await widget.cropper!.crop(_file);
                        if (mounted) setState(() => _file = cropped);
                      },
                      icon: const Icon(Icons.crop),
                      label: const Text('Crop / ক্রপ'),
                    ),
                  ),
                if (widget.cropper != null) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _rotation = (_rotation + 90) % 360),
                    icon: const Icon(Icons.rotate_right),
                    label: const Text('Rotate / ঘোরান'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.onUse(
                        CapturePage(file: _file, rotation: _rotation),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Use page / ব্যবহার করুন'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class MultiPageReviewScreen extends StatefulWidget {
  const MultiPageReviewScreen({
    required this.draft,
    required this.onContinue,
    required this.onAddPage,
    this.onRetake,
    super.key,
  });
  final MultiPageCaptureDraft draft;
  final ValueChanged<MultiPageCaptureDraft> onContinue;
  final VoidCallback onAddPage;
  final ValueChanged<int>? onRetake;
  @override
  State<MultiPageReviewScreen> createState() => _MultiPageReviewScreenState();
}

class _MultiPageReviewScreenState extends State<MultiPageReviewScreen> {
  late MultiPageCaptureDraft _draft;
  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Review pages / পৃষ্ঠা দেখুন (${_draft.pageCount})'),
    ),
    body: ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _draft.pages.length,
      onReorderItem: (oldIndex, newIndex) =>
          setState(() => _draft = _draft.reorderItem(oldIndex, newIndex)),
      itemBuilder: (context, index) {
        final page = _draft.pages[index];
        return Card(
          key: ValueKey(page.file.path),
          child: ListTile(
            leading: SizedBox(
              width: 56,
              height: 56,
              child: Image.file(page.file, fit: BoxFit.cover),
            ),
            title: Text('Page ${index + 1} / পৃষ্ঠা ${index + 1}'),
            subtitle: Text('Rotation: ${page.rotation}°'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onRetake != null)
                  IconButton(
                    onPressed: () => widget.onRetake!(index),
                    tooltip: 'Retake page / আবার তুলুন',
                    icon: const Icon(Icons.refresh),
                  ),
                IconButton(
                  onPressed: () =>
                      setState(() => _draft = _draft.rotateClockwise(index)),
                  tooltip: 'Rotate / ঘোরান',
                  icon: const Icon(Icons.rotate_right),
                ),
                IconButton(
                  onPressed: () async {
                    if (_draft.pageCount == 1) {
                      final remove = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Discard scan? / স্ক্যান বাতিল করবেন?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Keep / রাখুন'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Discard / বাতিল'),
                            ),
                          ],
                        ),
                      );
                      if (remove == true && mounted) {
                        Navigator.pop(this.context);
                      }
                    } else {
                      setState(() => _draft = _draft.removeAt(index));
                    }
                  },
                  tooltip: 'Delete page / পৃষ্ঠা মুছুন',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onAddPage,
                icon: const Icon(Icons.add),
                label: const Text('Add page / পৃষ্ঠা যোগ করুন'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _draft.pages.isEmpty
                    ? null
                    : () => widget.onContinue(_draft),
                child: const Text('Continue / চালিয়ে যান'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
