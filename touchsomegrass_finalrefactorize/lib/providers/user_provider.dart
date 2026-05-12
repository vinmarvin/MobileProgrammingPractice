import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  FirestoreService? _service;

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user      => _user;
  bool get isLoading       => _isLoading;

  FirestoreService get _serviceInstance => _service ??= FirestoreService();

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> loadUser(String uid) async {
    _setLoading(true);
    _user = await _serviceInstance.getUser(uid);
    _setLoading(false);
  }

  void listenToUser(String uid) {
    _serviceInstance.userStream(uid).listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Update nama, role, dan (opsional) avatar emoji ke Firestore.
  Future<void> updateProfile(
    String uid,
    String name,
    String role, {
    String? avatarEmoji,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'role': role,
      if (avatarEmoji != null) 'avatar_emoji': avatarEmoji,
    };
    await _serviceInstance.updateUser(uid, data);
    if (_user != null) {
      _user = _user!.copyWith(
        name: name,
        role: role,
        avatarEmoji: avatarEmoji,
      );
      notifyListeners();
    }
  }

  Future<void> addPoints(String uid, int points, int minutes) async {
    await _serviceInstance.addPointsAndMinutes(uid, points, minutes);
  }

  Future<void> deductPoints(String uid, int cost) async {
    await _serviceInstance.deductPoints(uid, cost);
    if (_user != null) {
      _user = _user!.copyWith(points: (_user!.points - cost).clamp(0, 999999));
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
