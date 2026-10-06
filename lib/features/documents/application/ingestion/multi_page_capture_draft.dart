import 'dart:io';

import 'import_models.dart';

abstract interface class DocumentCropper {
  Future<File> crop(File image);
}

class CapturePage {
  const CapturePage({required this.file, this.rotation = 0});
  final File file;
  final int rotation;
  CapturePage copyWith({File? file, int? rotation}) =>
      CapturePage(file: file ?? this.file, rotation: rotation ?? this.rotation);
}

/// In-memory review state. Files remain in a private camera/picker cache only
/// until [SecureImportService.stage] copies them into the vault workspace.
class MultiPageCaptureDraft {
  const MultiPageCaptureDraft([this.pages = const []]);
  final List<CapturePage> pages;
  int get pageCount => pages.length;

  MultiPageCaptureDraft add(File file) =>
      MultiPageCaptureDraft([...pages, CapturePage(file: file)]);
  MultiPageCaptureDraft removeAt(int index) =>
      MultiPageCaptureDraft([...pages]..removeAt(index));
  MultiPageCaptureDraft retake(int index, File file) =>
      MultiPageCaptureDraft([...pages]..[index] = CapturePage(file: file));
  MultiPageCaptureDraft rotateClockwise(int index) => MultiPageCaptureDraft([
    for (var i = 0; i < pages.length; i++)
      i == index
          ? pages[i].copyWith(rotation: (pages[i].rotation + 90) % 360)
          : pages[i],
  ]);
  MultiPageCaptureDraft reorder(int oldIndex, int newIndex) {
    final reordered = [...pages];
    final page = reordered.removeAt(oldIndex);
    reordered.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, page);
    return MultiPageCaptureDraft(reordered);
  }

  MultiPageCaptureDraft reorderItem(int oldIndex, int newIndex) {
    final reordered = [...pages];
    final page = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, page);
    return MultiPageCaptureDraft(reordered);
  }

  List<SelectedImportFile> asImportFiles() => pages
      .map(
        (page) => SelectedImportFile(
          file: page.file,
          source: ImportSource.camera,
          rotation: page.rotation,
        ),
      )
      .toList(growable: false);
}
