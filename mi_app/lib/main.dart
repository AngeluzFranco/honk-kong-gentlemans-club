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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB), // primary
              Color(0xFF3B82F6), // secondary
              Color(0xFF0EA5E9), // accent
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con efecto de elevación
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Título con sombra
              Text(
                'AutoManager',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 12),
              // Subtítulo
              Text(
                'Gestiona tus vehículos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 60),
              // Indicador de carga moderno
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
