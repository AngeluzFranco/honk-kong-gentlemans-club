import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'config/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/vehicle_viewmodel.dart';
import 'services/firebase_notification_service.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

FirebaseOptions _getFirebaseOptions() {
  if (Platform.isAndroid) {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCVzYng4RteaCR8dAWV-LV7UPasjlez8sU',
      appId: '1:412244173384:android:f56ac685be5ea971a62e7d',
      messagingSenderId: '412244173384',
      projectId: 'automanager-a8227',
      storageBucket: 'automanager-a8227.firebasestorage.app',
    );
  }
  // Para iOS (si lo agregas después)
  throw UnsupportedError('Plataforma no soportada');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (solo si está configurado)
  try {
    await Firebase.initializeApp(options: _getFirebaseOptions());
    
    // Inicializar notificaciones push
    final notificationService = FirebaseNotificationService();
    await notificationService.initialize();
    
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('⚠️ Firebase no configurado: $e');
    debugPrint('La app funcionará sin notificaciones push por ahora');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => VehicleViewModel()),
      ],
      child: MaterialApp(
        title: 'AutoManager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Retrasar la inicialización hasta después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.init();

    if (!mounted) return;

    // Obtener y actualizar token FCM (solo si Firebase está configurado)
    try {
      final notificationService = FirebaseNotificationService();
      final fcmToken = await notificationService.getFcmToken();
      if (fcmToken != null && authViewModel.isLoggedIn) {
        await authViewModel.updateFcmToken(fcmToken);
      }
    } catch (e) {
      debugPrint('⚠️ No se pudo obtener token FCM: $e');
    }

    // Navegar a la pantalla correspondiente
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => authViewModel.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_car,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'AutoManager',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tus vehículos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
