import 'dart:io';

import 'package:camera/camera.dart';

import '../../../core/errors/app_failure.dart';

/// Thin platform adapter around the live camera package. The caller must first
/// run [IngestionPermissionService.ensureCamera] after the user's Scan action.
class DeviceCameraCapture {
  CameraController? _controller;
  CameraController get controller {
    final value = _controller;
    if (value == null) throw StateError('Camera has not been opened.');
    return value;
  }

  Future<void> open() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back)
          .firstOrNull;
      final selected = backCamera ?? cameras.firstOrNull;
      if (selected == null) {
        throw CameraException('no_camera', 'No camera is available.');
      }
      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      _controller = controller;
    } on Object catch (error) {
      throw StorageFailure('Camera could not be opened.', cause: error);
    }
  }

  Future<bool> toggleFlash() async {
    final camera = controller;
    final current = camera.value.flashMode;
    final next = current == FlashMode.torch ? FlashMode.off : FlashMode.torch;
    await camera.setFlashMode(next);
    return next == FlashMode.torch;
  }

  Future<File> capture() async {
    try {
      final capture = await controller.takePicture();
      return File(capture.path);
    } on Object catch (error) {
      throw StorageFailure('Camera capture failed.', cause: error);
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
