import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_problematico_catalog/app.dart';

void main() {
  testWidgets('renders product list page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Catalogo Problematico'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
