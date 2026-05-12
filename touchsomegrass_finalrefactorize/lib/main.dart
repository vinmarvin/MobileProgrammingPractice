import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/community_provider.dart';
import 'providers/album_provider.dart';
import 'providers/timer_provider.dart';
import 'services/ml_service.dart';
import 'services/plant_database_service.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/main_navigation.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pre-load essential services (AI Model & Plant Database)
  final mlService = MLService();
  final dbService = PlantDatabaseService();
  
  await Future.wait([
    mlService.initModel(),
    dbService.init(),
  ]);

  runApp(const TouchSomeGrassApp());

  unawaited(_initializeNotifications());
}

Future<void> _initializeNotifications() async {
  try {
    await NotificationService.initializeNotification();
  } catch (e, st) {
    debugPrint('Notification initialization failed: $e');
    debugPrint('$st');
  }
}

class TouchSomeGrassApp extends StatelessWidget {
  const TouchSomeGrassApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => AlbumProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp(
        title: 'TouchSomeGrass',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String? _listeningUid;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final uid = authProvider.firebaseUser?.uid;

    if (authProvider.isLoggedIn) {
      if (uid != null && uid != _listeningUid) {
        _listeningUid = uid;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<UserProvider>().listenToUser(uid);
        });
      }
      return const MainNavigation();
    }

    _listeningUid = null;
    return const LoginScreen();
  }
}
