import 'package:flutter/material.dart';
import 'balance_sheet_widget.dart';
import 'tasks_widget.dart';
import 'base_scaffold.dart';
import 'base_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Typed keys for child page states
  final GlobalKey<BasePageState> _balanceKey = GlobalKey<BasePageState>();
  final GlobalKey<BasePageState> _tasksKey = GlobalKey<BasePageState>();

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      pages: [
        BalanceSheetWidget(key: _balanceKey),
        TasksWidget(key: _tasksKey),
      ],
      pageKeys: [_balanceKey, _tasksKey],
      currentIndex: _currentIndex,
      onIndexChanged: (i) => setState(() => _currentIndex = i),
    );
  }
}

