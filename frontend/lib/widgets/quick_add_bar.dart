import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A compact, Google Tasks–style bottom quick-add bar.
///
/// Usage:
/// - Pass the main controller and focusNode for the primary text input.
/// - Provide an [expandedContent] widget that will be shown above the main row
///   when [expanded] is true (e.g. additional TextFields).
class QuickAddBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool expanded;
  final VoidCallback toggleExpanded;
  final VoidCallback onSend;
  final Widget? expandedContent;
  final String hintText;
  final bool sendEnabled;

  const QuickAddBar({
    Key? key,
    required this.controller,
    this.focusNode,
    this.expanded = false,
    required this.toggleExpanded,
    required this.onSend,
    this.expandedContent,
    this.hintText = 'Add...',
    this.sendEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.spacing, AppTheme.spacingSmall, AppTheme.spacing, AppTheme.spacingSmall),
          child: Material(
            elevation: 2,
            // remove rounded corners for a flatter, edge-to-edge look
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            // use a slightly darker surface container color to make the bar more visible
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing, vertical: AppTheme.spacingSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (expanded && expandedContent != null) ...[
                    expandedContent!,
                    const SizedBox(height: AppTheme.spacingSmall),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: hintText,
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => onSend(),
                        ),
                      ),

                      // Only show expand when input is valid
                      if (sendEnabled)
                        IconButton(
                          icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                          onPressed: toggleExpanded,
                          tooltip: expanded ? 'Hide fields' : 'Show more fields',
                        ),

                      // Save icon; disabled when sendEnabled is false. When enabled show green color.
                      IconButton(
                        icon: Icon(Icons.save, color: sendEnabled ? Colors.green : null),
                        onPressed: sendEnabled ? onSend : null,
                        tooltip: sendEnabled ? 'Save' : 'Fill required fields',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
