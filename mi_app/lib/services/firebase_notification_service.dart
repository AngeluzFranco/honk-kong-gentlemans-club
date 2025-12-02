import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Solicitar permisos
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
      return;
    }

    // Crear canal de notificación para Android
    const androidChannel = AndroidNotificationChannel(
      'vehicle_channel',
      'Vehículos',
      description: 'Notificaciones sobre vehículos',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Configurar notificaciones locales
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Obtener token FCM
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await _saveFcmToken(token);
    }

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen(_saveFcmToken);

    // Configurar handlers para diferentes estados
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Verificar si la app fue abierta desde una notificación
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.fcmTokenKey, token);
    // Aquí puedes enviar el token al backend
    print('FCM Token saved: $token');
  }

  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    _handleNotificationNavigation(message);
  }

  void _handleInitialMessage(RemoteMessage message) {
    print('App opened from notification!');
    _handleNotificationNavigation(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Aquí puedes navegar a una pantalla específica
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    // Implementar navegación basada en los datos del mensaje
    final data = message.data;
    
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      print('Navigate to: $screen');
      
      // Ejemplo de navegación
      // if (screen == 'vehicle_detail') {
      //   final vehicleId = data['vehicleId'];
      //   // Navegar a la pantalla de detalle
      // }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // Enviar notificación local cuando se crea un vehículo
  Future<void> sendVehicleCreatedNotification({
    required String brand,
    required String model,
    required String year,
    String? imageUrl,
  }) async {
    final StyleInformation? bigPictureStyle = imageUrl != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(imageUrl),
            contentTitle: 'Vehículo Creado',
            summaryText: '$brand $model $year se agregó exitosamente a tu flota',
            hideExpandedLargeIcon: false,
          )
        : null;

    final androidDetails = AndroidNotificationDetails(
      'vehicle_channel',
      'Vehículos',
      channelDescription: 'Notificaciones sobre vehículos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: 'ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: bigPictureStyle ?? const DefaultStyleInformation(true, true),
      color: const Color(0xFF2563EB),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: [],
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Vehículo Creado',
      '$brand $model $year se agregó exitosamente a tu flota',
      notificationDetails,
    );
  }

  // Enviar notificación local cuando se actualiza un vehículo
  Future<void> sendVehicleUpdatedNotification({
    required String brand,
    required String model,
    required String year,
    String? imageUrl,
  }) async {
    final StyleInformation? bigPictureStyle = imageUrl != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(imageUrl),
            contentTitle: 'Vehículo Actualizado',
            summaryText: '$brand $model $year se actualizó correctamente',
            hideExpandedLargeIcon: false,
          )
        : null;

    final androidDetails = AndroidNotificationDetails(
      'vehicle_channel',
      'Vehículos',
      channelDescription: 'Notificaciones sobre vehículos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: 'ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: bigPictureStyle ?? const DefaultStyleInformation(true, true),
      color: const Color(0xFF2563EB),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: [],
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Vehículo Actualizado',
      '$brand $model $year se actualizó correctamente',
      notificationDetails,
    );
  }
}
