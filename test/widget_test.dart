// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:agencitas/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgencitasApp());

    // Verify that our main screen loads
    expect(find.text('¡Bienvenido a Agencitas!'), findsOneWidget);
    expect(find.text('Sistema integral de gestión de citas médicas'), findsOneWidget);

    // Verify the main action buttons are present
    expect(find.text('Registrar Paciente'), findsOneWidget);
    expect(find.text('Agendar Cita'), findsOneWidget);
  });
}
