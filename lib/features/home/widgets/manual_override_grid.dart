import 'package:flutter/material.dart';
import 'package:kairo/features/home/widgets/kairo_activity_item.dart';

class ManualOverrideGrid extends StatelessWidget {
  const ManualOverrideGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: const [
        KairoActivityItem(icon: Icons.bolt, label: 'Deep Work', isActive: true),
        KairoActivityItem(icon: Icons.groups_outlined, label: 'Meeting'),
        KairoActivityItem(icon: Icons.coffee_outlined, label: 'Break'),
        KairoActivityItem(icon: Icons.restaurant_outlined, label: 'Lunch'),
        KairoActivityItem(icon: Icons.lightbulb_outline, label: 'Ideation'),
        KairoActivityItem(icon: Icons.fireplace_outlined, label: 'Urgent'),
      ],
    );
  }
}
