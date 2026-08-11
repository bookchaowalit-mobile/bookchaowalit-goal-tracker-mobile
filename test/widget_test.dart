import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/main.dart';

void main() {
  testWidgets('Goal Tracker app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const GoalTrackerApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Goal Tracker'), findsWidgets);
  });
}
