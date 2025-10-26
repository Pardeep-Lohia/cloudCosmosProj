import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(8),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
