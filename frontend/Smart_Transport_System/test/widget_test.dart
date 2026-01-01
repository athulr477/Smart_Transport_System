import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_transport_frontend/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTransportApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
