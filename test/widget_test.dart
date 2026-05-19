import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:color_vision_app/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ColorVisionApp());

    // Verify that the title is present
    expect(find.text('Vision Assist'), findsWidgets);
  });
}

