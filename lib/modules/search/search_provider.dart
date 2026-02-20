import 'package:flutter/foundation.dart';
import '../template/template_models.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';

/// SearchProvider - Handles global search across the app
class SearchProvider extends ChangeNotifier {
  SearchState _state = const SearchState();

  SearchState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  List<SearchResult> get results => _state.results;
  bool get hasResults => _state.results.isNotEmpty;

  /// Perform global search
  Future<void> search(String query, {String? workspaceId}) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final normalizedQuery = query.toLowerCase().trim();
      final List<SearchResult> allResults = [];

      // Search requests
      final requestResults =
          await _searchRequests(normalizedQuery, workspaceId);
      allResults.addAll(requestResults);

      // Search templates
      final templateResults =
          await _searchTemplates(normalizedQuery, workspaceId);
      allResults.addAll(templateResults);

      // Search workspaces
      final workspaceResults = await _searchWorkspaces(normalizedQuery);
      allResults.addAll(workspaceResults);

      // Sort by relevance
      allResults.sort((a, b) => b.relevance.compareTo(a.relevance));

      _state = _state.copyWith(results: allResults);
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Search requests
  Future<List<SearchResult>> _searchRequests(
      String query, String? workspaceId) async {
    // This would be implemented with actual repository calls
    // For now, return empty list
    return [];
  }

  /// Search templates
  Future<List<SearchResult>> _searchTemplates(
      String query, String? workspaceId) async {
    // This would be implemented with actual repository calls
    return [];
  }

  /// Search workspaces
  Future<List<SearchResult>> _searchWorkspaces(String query) async {
    // This would be implemented with actual repository calls
    return [];
  }

  /// Clear search results
  void clearResults() {
    _state = _state.copyWith(results: [], error: null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  void _setError(String error) {
    _state = _state.copyWith(error: error);
    notifyListeners();
  }

  void _clearError() {
    _state = _state.copyWith(error: null);
  }
}

/// Search state
class SearchState {
  final bool isLoading;
  final List<SearchResult> results;
  final String? error;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    List<SearchResult>? results,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}

/// Search result item
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final DateTime? date;
  final String? workspaceId;
  final double relevance;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.date,
    this.workspaceId,
    this.relevance = 0.0,
  });
}

enum SearchResultType {
  request,
  template,
  workspace,
}
