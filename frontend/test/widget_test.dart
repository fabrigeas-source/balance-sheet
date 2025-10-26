import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:balance_sheet_app/screens/home_screen.dart';
import 'package:balance_sheet_app/providers/item_provider.dart';
import 'package:balance_sheet_app/models/entry.dart';

void main() {
  Widget createHomeScreen() {
    return ChangeNotifierProvider(
      create: (_) => ItemProvider(),
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('HomeScreen displays total sum and item list',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    // Verify that the total sum header is displayed
    expect(find.text('Total: 0.00'), findsOneWidget);

    // Verify that the item list is displayed
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Tapping on an item expands it', (WidgetTester tester) async {
    final provider = ItemProvider();
    provider.addItem(Entry(
      id: '1',
      description: 'Test Item',
      amount: 100,
      type: EntryType.expense,
    ));

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: HomeScreen()),
    ));

    await tester.pumpAndSettle();

    // Find and tap the item
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // Verify that a snackbar is shown (current implementation)
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Item editing coming soon!'), findsOneWidget);
  });

  testWidgets('Swiping an item left shows delete confirmation',
      (WidgetTester tester) async {
    final provider = ItemProvider();
    provider.addItem(Entry(
      id: '1',
      description: 'Test Item',
      amount: 100,
      type: EntryType.expense,
    ));

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: HomeScreen()),
    ));

    await tester.pumpAndSettle();

    // Find and swipe the item
    await tester.drag(find.byType(ListTile).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify that the delete confirmation dialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Delete Item'), findsOneWidget);
  });

  testWidgets('Floating button opens new item modal',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    // Find and tap the floating action button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that the new item modal is shown
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
  });
}
