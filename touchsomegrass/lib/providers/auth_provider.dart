import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth? _auth;
  FirestoreService? _firestoreService;

  User? _firebaseUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirestoreService get _firestoreServiceInstance =>
      _firestoreService ??= FirestoreService();

  AuthProvider({
    FirebaseAuth? auth,
    FirestoreService? firestoreService,
    bool listenToAuthState = true,
  })  : _auth = auth,
        _firestoreService = firestoreService {
    if (listenToAuthState) {
      _firebaseUser = _firebaseAuth.currentUser;
      _firebaseAuth.authStateChanges().listen((user) {
        _firebaseUser = user;
        notifyListeners();
      });
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_parseError(e.code));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      final uid = credential.user!.uid;

      // Create user document in Firestore
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        role: 'Member',
        points: 0,
        totalFocusMinutes: 0,
      );
      await _firestoreServiceInstance.createUser(newUser);

      // Seed communities if not yet seeded
      await _firestoreServiceInstance.seedCommunities();

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_parseError(e.code));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  String _parseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
