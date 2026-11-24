
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('TaskFlow welcome screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.text('Welcome to TaskFlow'), findsOneWidget);
  });
}
