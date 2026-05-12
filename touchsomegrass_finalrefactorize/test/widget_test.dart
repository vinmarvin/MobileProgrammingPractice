import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:provider/provider.dart';
import 'package:touch_some_grass/models/community_model.dart';
import 'package:touch_some_grass/models/user_model.dart';
import 'package:touch_some_grass/providers/album_provider.dart';
import 'package:touch_some_grass/providers/auth_provider.dart' as app_auth;
import 'package:touch_some_grass/providers/community_provider.dart';
import 'package:touch_some_grass/providers/timer_provider.dart';
import 'package:touch_some_grass/providers/user_provider.dart';
import 'package:touch_some_grass/widgets/main_navigation.dart';

class FakeAuthProvider extends app_auth.AuthProvider {
  FakeAuthProvider() : super(listenToAuthState: false);

  @override
  fa.User? get firebaseUser => null;

  @override
  bool get isLoggedIn => false;
}

class FakeUserProvider extends UserProvider {
  FakeUserProvider(this._user);

  final UserModel _user;

  @override
  UserModel? get user => _user;

  @override
  bool get isLoading => false;

  @override
  Future<void> loadUser(String uid) async {}

  @override
  void listenToUser(String uid) {}

  @override
  Future<void> updateProfile(
    String uid,
    String name,
    String role, {
    String? avatarEmoji,
  }) async {}

  @override
  Future<void> addPoints(String uid, int points, int minutes) async {}

  @override
  void clearUser() {}
}

class FakeCommunityProvider extends CommunityProvider {
  FakeCommunityProvider();

  @override
  List<CommunityModel> get communities => const [];

  @override
  bool get isLoading => false;

  @override
  Future<void> loadCommunities() async {}

  @override
  void search(String query) {}

  @override
  void clearSearch() {}
}

class FakeAlbumProvider extends AlbumProvider {
  FakeAlbumProvider();

  @override
  List<PhotoEntry> get entries => const [];

  @override
  bool get isLoading => false;

  @override
  Future<void> loadPhotos() async {}

  @override
  Future<PickedPhotoData?> pickFromCamera() async => null;

  @override
  Future<PickedPhotoData?> pickFromGallery() async => null;

  @override
  Future<void> savePhotoWithTwibbon({
    required String path,
    required int twibbonIndex,
    String? location,
  }) async {}

  @override
  Future<void> deletePhoto(String path) async {}
}

void main() {
  testWidgets('Main navigation renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<app_auth.AuthProvider>(
            create: (_) => FakeAuthProvider(),
          ),
          ChangeNotifierProvider<UserProvider>(
            create: (_) => FakeUserProvider(
              UserModel(
                uid: 'test-uid',
                name: 'Test User',
                role: 'Member',
                points: 120,
                totalFocusMinutes: 90,
              ),
            ),
          ),
          ChangeNotifierProvider<CommunityProvider>(
            create: (_) => FakeCommunityProvider(),
          ),
          ChangeNotifierProvider<AlbumProvider>(
            create: (_) => FakeAlbumProvider(),
          ),
          ChangeNotifierProvider<TimerProvider>(
            create: (_) => TimerProvider(),
          ),
        ],
        child: const MaterialApp(
          home: MainNavigation(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Komunitas'), findsOneWidget);
    expect(find.text('Album'), findsOneWidget);
    expect(find.text('Grassbook'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
