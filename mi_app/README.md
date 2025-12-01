# 🚗 Mi App - Gestión de Vehículos

Aplicación móvil desarrollada en Flutter para la gestión integral de vehículos personales, con autenticación de usuarios y almacenamiento en la nube.

## 📋 Descripción

Mi App es una aplicación completa que permite a los usuarios:
- Registrar y gestionar su flota de vehículos personales
- Almacenar información detallada de cada vehículo (marca, modelo, año, kilometraje, etc.)
- Capturar y almacenar fotos de los vehículos
- Registrar ubicación GPS de cada vehículo
- Llevar control de mantenimientos y servicios
- Autenticación segura con Firebase
- Sincronización en la nube con AWS

## ✨ Características

### Autenticación
- ✅ Registro de usuarios con email y contraseña
- ✅ Inicio de sesión seguro con Firebase Auth
- ✅ Gestión de sesiones persistentes
- ✅ Cierre de sesión

### Gestión de Vehículos
- ✅ Crear nuevos vehículos con información detallada
- ✅ Visualizar lista completa de vehículos
- ✅ Ver detalles específicos de cada vehículo
- ✅ Editar información de vehículos existentes
- ✅ Eliminar vehículos
- ✅ Captura de fotos desde cámara o galería
- ✅ Compresión automática de imágenes (formato Base64)
- ✅ Registro de ubicación GPS del vehículo

### Información Almacenada
- Marca y modelo
- Año de fabricación
- Placa/matrícula
- Color
- Kilometraje actual
- Fecha de compra
- Fecha del último servicio
- Fecha del próximo servicio
- Kilometraje del próximo servicio
- Notas adicionales
- Fotografía del vehículo
- Ubicación GPS (latitud/longitud)

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **Dio** - Cliente HTTP para llamadas a API

### Backend y Servicios
- **Firebase Authentication** - Autenticación de usuarios
- **Firebase Cloud Firestore** - Almacenamiento de datos de usuarios
- **AWS Lambda** - Funciones serverless para lógica de negocio
- **AWS DynamoDB** - Base de datos NoSQL para vehículos
- **AWS API Gateway** - API REST para comunicación con Lambda

### Dependencias Principales
```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  provider: ^6.1.1
  dio: ^5.4.0
  image_picker: ^1.0.7
  image: ^4.1.7
  geolocator: ^11.0.0
  google_maps_flutter: ^2.5.3
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^17.0.0
  firebase_messaging: ^14.7.10
```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK (>=3.5.4 <4.0.0)
- Dart SDK
- Android Studio / Xcode (para desarrollo móvil)
- Cuenta de Firebase
- Cuenta de AWS (para backend)

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/AngeluzFranco/honk-kong-gentlemans-club.git
cd mi_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configuración de Firebase**
   - El archivo `google-services.json` ya está incluido en `android/app/`
   - Para iOS, agrega `GoogleService-Info.plist` en `ios/Runner/`

4. **Configuración de AWS** (Opcional - solo si quieres tu propio backend)
   - Edita `lib/config/api_config.dart` con tus endpoints de AWS
   - Configura las funciones Lambda según `AWS_SETUP_GUIDE.md`

5. **Ejecutar la aplicación**
```bash
flutter run
```

## 🏗️ Arquitectura del Proyecto

```
lib/
├── config/           # Configuración de Firebase y AWS
├── models/           # Modelos de datos (User, Vehicle)
├── services/         # Servicios de API y autenticación
├── viewmodels/       # Lógica de negocio y gestión de estado
├── views/            # Pantallas de la aplicación
│   ├── auth/         # Login y registro
│   ├── home/         # Pantalla principal
│   └── vehicles/     # Gestión de vehículos
├── widgets/          # Widgets reutilizables
├── utils/            # Utilidades y helpers
└── main.dart         # Punto de entrada de la aplicación
```

## 🔐 Seguridad

- Autenticación mediante Firebase Auth
- Tokens JWT para comunicación con AWS
- Validación de datos en cliente y servidor
- Imágenes comprimidas y almacenadas en Base64 (<300KB)

## 📊 Backend (AWS)

### Funciones Lambda
- **CreateVehicle** - Crear nuevo vehículo
- **GetVehicles** - Obtener lista de vehículos del usuario
- **UpdateVehicle** - Actualizar información de vehículo
- **DeleteVehicle** - Eliminar vehículo

### DynamoDB
- **Tabla:** `vehicles`
- **Partition Key:** `id` (UUID)
- **Sort Key:** `userId` (Firebase UID)

## 🧪 Testing

```bash
flutter test
```

## 📄 Licencia

Este proyecto es de código abierto y está disponible para uso educativo.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request
