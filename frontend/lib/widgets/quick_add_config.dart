import 'package:flutter/material.dart';

/// Lightweight holder for configuring the shared QuickAddBar from a parent.
class QuickAddConfig {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool expanded;
  final VoidCallback toggleExpanded;
  final VoidCallback onSend;
  final Widget expandedContent;
  final bool sendEnabled;
  final String hintText;

  QuickAddConfig({
    required this.controller,
    required this.focusNode,
    required this.expanded,
    required this.toggleExpanded,
    required this.onSend,
    required this.expandedContent,
    required this.sendEnabled,
    required this.hintText,
  });
}
