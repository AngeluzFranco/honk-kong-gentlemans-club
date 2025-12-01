# AutoManager - Aplicación de Gestión de Vehículos 🚗

## 📱 Descripción del Proyecto

AutoManager es una aplicación móvil multiplataforma desarrollada en Flutter que permite gestionar vehículos particulares de manera integral. Cumple con todos los requisitos del proyecto integrador.

### ✅ Requisitos Implementados:
- ✅ Arquitectura MVVM completa
- ✅ Backend en la nube (configurable)
- ✅ Autenticación JWT (Login + Registro)
- ✅ CRUD completo de vehículos
- ✅ Integración de cámara y galería
- ✅ Geolocalización con Google Maps
- ✅ Notificaciones Push con Firebase
- ✅ Persistencia con SharedPreferences
- ✅ UI/UX profesional Material Design

## 🚀 Configuración Rápida

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Configurar Backend
Edita `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://tu-backend.com/api';
```

### 3. Configurar Firebase
- Descarga `google-services.json` y colócalo en `android/app/`
- Descarga `GoogleService-Info.plist` y colócalo en `ios/Runner/`

### 4. Configurar Google Maps API Key
En `android/app/src/main/AndroidManifest.xml` agrega tu API Key dentro de `<application>`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

### 5. Ejecutar
```bash
flutter run
```

## 📦 Estructura MVVM

```
lib/
├── config/           # Configuración (API, Theme)
├── models/           # Modelos de datos
├── services/         # Servicios (API, Firebase)
├── viewmodels/       # Lógica de negocio
├── views/            # Pantallas UI
│   ├── auth/         # Login, Register
│   ├── home/         # Home principal
│   └── vehicles/     # CRUD vehículos
└── utils/            # Validadores, helpers
```

## 🔧 Funcionalidades

### 🔐 Autenticación
- Login con email/password
- Registro con validación en tiempo real
- JWT tokens + persistencia de sesión
- Logout funcional

### 🚙 Gestión de Vehículos (CRUD)
- **Lista**: Ver todos los vehículos
- **Detalle**: Información completa + mapa
- **Crear**: Agregar nuevo vehículo
- **Editar**: Modificar vehículo
- **Eliminar**: Con confirmación

### 📸 Cámara
- Tomar foto
- Seleccionar de galería
- Compresión automática
- Subida a la nube

### 📍 Geolocalización
- Obtener ubicación GPS
- Mostrar en Google Maps
- Guardar coordenadas

### 🔔 Notificaciones Push
- Firebase Cloud Messaging
- Manejo foreground/background
- Navegación desde notificación

## 📝 Endpoints Backend Requeridos

```
POST /api/auth/login
POST /api/auth/register
POST /api/auth/refresh
GET  /api/vehicles
POST /api/vehicles
GET  /api/vehicles/:id
PUT  /api/vehicles/:id
DELETE /api/vehicles/:id
POST /api/upload/image/:vehicleId
```

## 🐛 Troubleshooting

**MissingPluginException:**
```bash
flutter clean && flutter pub get && flutter run
```

**Firebase no configurado:**
Verifica que los archivos de configuración estén en las rutas correctas.

**Google Maps no muestra:**
Verifica tu API Key y que los SDKs estén habilitados.

## 📚 Recursos
- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Flutter](https://firebase.flutter.dev/)
- [Provider](https://pub.dev/packages/provider)

## 👨‍💻 Proyecto Integrador
Desarrollo Móvil - Unidad I
