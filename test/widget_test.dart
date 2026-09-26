import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exploraec/main.dart';

void main() {
  testWidgets('La bienvenida muestra ícono, título, subtítulo y botón',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());

    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    expect(find.text('ExploraEC'), findsOneWidget);
    expect(find.text('Descubre lugares increíbles cerca de ti'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Empezar'), findsOneWidget);
  });

  testWidgets('El botón Empezar invoca el callback', (WidgetTester tester) async {
    var pulsado = 0;
    await tester.pumpWidget(
      MaterialApp(home: BienvenidaScreen(onEmpezar: () => pulsado++)),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Empezar'));
    await tester.pump();

    expect(pulsado, 1);
  });
}
