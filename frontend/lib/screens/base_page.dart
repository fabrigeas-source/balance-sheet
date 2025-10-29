import 'package:flutter/material.dart';
import '../widgets/quick_add_config.dart';
import '../theme/app_theme.dart';

/// Base page widget/state that hosts common breadcrumb + selection behavior
/// used by BalanceSheetWidget and TasksWidget.
abstract class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  final List<dynamic> breadcrumbs = [];
  String? currentParentId;

  // Selection state (children should clear their own selected sets when exited)
  bool selectionMode = false;

  /// Child must provide a screen title
  String get screenTitle;

  /// Child must provide QuickAdd configuration
  QuickAddConfig getQuickAddConfig();

  bool get isSelectionMode => selectionMode;

  void toggleSelectionMode() {
    setState(() {
      selectionMode = !selectionMode;
      if (!selectionMode) onSelectionModeExited();
    });
  }

  /// Called when selection mode is exited so child can clear its selected set.
  @protected
  void onSelectionModeExited() {}

  void navigateToSub(dynamic item) {
    setState(() {
      breadcrumbs.add(item);
      currentParentId = item.id;
    });
  }

  void navigateToBreadcrumb(int index) {
    setState(() {
      if (index == -1) {
        breadcrumbs.clear();
        currentParentId = null;
      } else {
        breadcrumbs.removeRange(index + 1, breadcrumbs.length);
        currentParentId = breadcrumbs.isEmpty ? null : breadcrumbs.last.id;
      }
    });
  }

  Widget buildBreadcrumbs(BuildContext context) {
    if (breadcrumbs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing, vertical: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => navigateToBreadcrumb(-1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingSmall),
                  child: Row(
                    children: [
                      Icon(
                        Icons.home,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < breadcrumbs.length; i++) ...[
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                InkWell(
                  onTap: i < breadcrumbs.length - 1 ? () => navigateToBreadcrumb(i) : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingSmall),
                    child: Text(
                      breadcrumbs[i].description,
                      style: TextStyle(
                        color: i < breadcrumbs.length - 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: i < breadcrumbs.length - 1 ? FontWeight.w500 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
