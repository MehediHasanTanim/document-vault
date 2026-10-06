import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../application/ingestion/import_models.dart';

abstract interface class DeviceImportPicker {
  Future<List<SelectedImportFile>> pickPhotos();
  Future<List<SelectedImportFile>> pickPdfOrFile();
}

class ImagePickerDeviceImportPicker implements DeviceImportPicker {
  ImagePickerDeviceImportPicker({ImagePicker? imagePicker})
    : _images = imagePicker ?? ImagePicker();
  final ImagePicker _images;

  @override
  Future<List<SelectedImportFile>> pickPhotos() async =>
      (await _images.pickMultiImage())
          .map(
            (image) => SelectedImportFile(
              file: File(image.path),
              source: ImportSource.photos,
              declaredMimeType: image.mimeType,
            ),
          )
          .toList(growable: false);

  @override
  Future<List<SelectedImportFile>> pickPdfOrFile() async {
    final selection = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    return selection
        .where((file) => file.path != null)
        .map(
          (file) => SelectedImportFile(
            file: File(file.path!),
            source: file.extension?.toLowerCase() == 'pdf'
                ? ImportSource.pdf
                : ImportSource.file,
          ),
        )
        .toList(growable: false);
  }
}
