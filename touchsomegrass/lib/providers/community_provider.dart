import 'package:flutter/foundation.dart';
import '../models/community_model.dart';
import '../services/firestore_service.dart';

class CommunityProvider extends ChangeNotifier {
  FirestoreService? _service;

  List<CommunityModel> _communities = [];
  List<CommunityModel> _filtered = [];
  bool _isLoading = false;
  String _searchQuery = '';

  FirestoreService get _serviceInstance => _service ??= FirestoreService();

  List<CommunityModel> get communities => _filtered;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadCommunities() async {
    _isLoading = true;
    notifyListeners();
    try {
      _communities = await _serviceInstance.getCommunities();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading communities: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_communities);
    } else {
      _filtered = _communities
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery) ||
              c.category.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filtered = List.from(_communities);
    notifyListeners();
  }
}
