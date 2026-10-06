import 'package:flutter/foundation.dart';

import '../library/document_library_models.dart';
import 'secure_search_index.dart';

class SecureSearchController extends ChangeNotifier {
  SecureSearchController(
    this._index, {
    InMemoryRecentSearches? recent,
    DateTime Function()? clock,
  }) : _recent = recent ?? InMemoryRecentSearches(),
       _clock = clock ?? DateTime.now;
  final SecureSearchIndex _index;
  final InMemoryRecentSearches _recent;
  final DateTime Function() _clock;
  var _query = '';
  var _filter = const DocumentLibraryFilter();
  List<SearchResult> _results = const [];

  String get query => _query;
  DocumentLibraryFilter get filter => _filter;
  List<SearchResult> get results => _results;
  List<String> get recentSearches => _recent.values;
  List<SearchSuggestion> get suggestions => _index.suggestions(_query);

  void search(String value) {
    _query = value;
    _results = _index.search(value, filter: _filter, clock: _clock);
    if (value.trim().isNotEmpty) _recent.add(value);
    notifyListeners();
  }

  void updateFilter(DocumentLibraryFilter value) {
    _filter = value;
    search(_query);
  }

  void clearQuery() {
    _query = '';
    _results = const [];
    notifyListeners();
  }

  void clearRecentSearches() {
    _recent.clear();
    notifyListeners();
  }
}
