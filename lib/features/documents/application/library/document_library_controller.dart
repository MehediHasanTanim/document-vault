import 'package:flutter/foundation.dart';

import 'document_library_models.dart';
import 'document_library_service.dart';

class DocumentLibraryController extends ChangeNotifier {
  DocumentLibraryController(this._library);
  final DocumentLibraryService _library;

  DocumentLibraryQuery _query = const DocumentLibraryQuery();
  List<DocumentCardData> _documents = const [];
  Object? _error;
  var _loading = false;

  DocumentLibraryQuery get query => _query;
  List<DocumentCardData> get documents => _documents;
  Object? get error => _error;
  bool get loading => _loading;

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _documents = await _library.browse(_query);
    } on Object catch (error) {
      _error = error;
      _documents = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> update(DocumentLibraryQuery value) async {
    _query = value;
    await refresh();
  }

  Future<void> setScope(
    DocumentLibraryScope scope, {
    String? categoryId,
    String? personId,
  }) => update(
    _query.copyWith(scope: scope, categoryId: categoryId, personId: personId),
  );

  Future<void> setSort(DocumentSort sort) =>
      update(_query.copyWith(sort: sort));
  Future<void> setFilter(DocumentLibraryFilter filter) =>
      update(_query.copyWith(filter: filter));
}
