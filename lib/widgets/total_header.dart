import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';

class TotalHeader extends StatelessWidget {
  const TotalHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = context.watch<ItemProvider>().total;
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Balance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: total >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
