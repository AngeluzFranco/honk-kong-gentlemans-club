import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthViewModel>().logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, VehicleViewModel>(
      builder: (context, authViewModel, vehicleViewModel, _) {
        final currentUser = authViewModel.currentUser;
        final totalVehicles = vehicleViewModel.vehicles.length;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).primaryColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header con información del usuario
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 48, 10, 32),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nombre
                      Text(
                        currentUser?.name ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        currentUser?.email ?? 'Sin email',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Estadísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.directions_car,
                        label: 'Vehículos',
                        value: totalVehicles.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_today,
                        label: 'Desde',
                        value: DateTime.now().year.toString(),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Opciones del perfil
              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Información Personal',
                subtitle: currentUser?.email ?? 'Sin información',
                onTap: () {
                  // Aquí podrías abrir una pantalla para editar perfil
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editar perfil próximamente')),
                  );
                },
              ),

              _ProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Configurar alertas',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuración de notificaciones próximamente')),
                  );
                },
              ),

              _ProfileOption(
                icon: Icons.security_outlined,
                title: 'Privacidad y Seguridad',
                subtitle: 'Gestionar contraseña y datos',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuración de seguridad próximamente')),
                  );
                },
              ),

              _ProfileOption(
                icon: Icons.help_outline,
                title: 'Ayuda y Soporte',
                subtitle: '¿Necesitas ayuda?',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Soporte'),
                      content: const Text(
                        'Para soporte, contacta a:\nsupport@automanager.com\n\n'
                        'O visita nuestra página de ayuda.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              _ProfileOption(
                icon: Icons.info_outline,
                title: 'Acerca de',
                subtitle: 'AutoManager v1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'AutoManager',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.directions_car, size: 48),
                    children: [
                      const Text(
                        'Aplicación para gestionar tu flota de vehículos.\n\n'
                        'Desarrollado con Flutter y Firebase.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Botón de cerrar sesión
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget para tarjetas de estadísticas
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color.fromARGB(255, 117, 117, 117),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para opciones del perfil
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
