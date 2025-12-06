import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/main.dart' as app;

/// Test de integración simple para verificar que la app inicia correctamente
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests de Integración Básicos', () {
    testWidgets('La aplicación inicia correctamente',
        (WidgetTester tester) async {
      print('🚀 Iniciando aplicación...');
      
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      print('✅ Aplicación iniciada');
      
      // Verificar que hay algún widget en pantalla
      expect(find.byType(MaterialApp), findsOneWidget);
      
      print('✅ MaterialApp encontrado');
      
      // Buscar si hay widgets comunes
      final scaffolds = find.byType(Scaffold);
      print('Scaffolds encontrados: ${scaffolds.evaluate().length}');
      
      final textFields = find.byType(TextFormField);
      print('TextFormFields encontrados: ${textFields.evaluate().length}');
      
      final buttons = find.byType(ElevatedButton);
      print('ElevatedButtons encontrados: ${buttons.evaluate().length}');
      
      final texts = find.byType(Text);
      print('Textos encontrados: ${texts.evaluate().length}');
      
      // Si encontramos texto, imprimir algunos
      if (texts.evaluate().isNotEmpty) {
        print('Primeros textos en pantalla:');
        for (var i = 0; i < texts.evaluate().length && i < 10; i++) {
          final widget = texts.evaluate().elementAt(i).widget as Text;
          if (widget.data != null && widget.data!.isNotEmpty) {
            print('  - ${widget.data}');
          }
        }
      }
      
      print('Test completado exitosamente!');
    });

    testWidgets('Navegar por la app (básico)',
        (WidgetTester tester) async {
      print('🧪 Probando navegación básica...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Buscar botones disponibles
      final buttons = find.byType(ElevatedButton);
      print('Botones disponibles: ${buttons.evaluate().length}');
      
      if (buttons.evaluate().isNotEmpty) {
        print('✅ Hay botones interactivos en la app');
        
        // Buscar texto de botones
        for (var i = 0; i < buttons.evaluate().length; i++) {
          final buttonWidget = buttons.evaluate().elementAt(i).widget;
          print('  Botón $i encontrado');
        }
      }
      
      // Buscar texto fields disponibles
      final textFields = find.byType(TextFormField);
      print('Campos de texto disponibles: ${textFields.evaluate().length}');
      
      if (textFields.evaluate().isNotEmpty) {
        print('✅ Hay campos de entrada en la app');
      }
      
      print('🎉 Test de navegación completado!');
    });

    testWidgets('Verificar estado inicial de la app',
        (WidgetTester tester) async {
      print('🔍 Verificando estado inicial...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verificar elementos comunes de la UI
      final widgets = <String, int>{
        'Scaffold': find.byType(Scaffold).evaluate().length,
        'AppBar': find.byType(AppBar).evaluate().length,
        'TextFormField': find.byType(TextFormField).evaluate().length,
        'ElevatedButton': find.byType(ElevatedButton).evaluate().length,
        'FloatingActionButton': find.byType(FloatingActionButton).evaluate().length,
        'ListView': find.byType(ListView).evaluate().length,
        'Card': find.byType(Card).evaluate().length,
      };
      
      print('Widgets en pantalla:');
      widgets.forEach((name, count) {
        if (count > 0) {
          print('  $name: $count');
        }
      });
      
      // Verificar que hay al menos algún contenido
      expect(find.byType(MaterialApp), findsOneWidget);
      
      print('Estado inicial verificado correctamente!');
    });
  });
}
