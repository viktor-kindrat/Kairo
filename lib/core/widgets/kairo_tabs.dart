import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class KairoTabs extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const KairoTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  @override
  State<KairoTabs> createState() => _KairoTabsState();
}

// SingleTickerProviderStateMixin потрібен для роботи анімацій у Flutter (vsync)
class _KairoTabsState extends State<KairoTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Створюємо контролер, який керуватиме анімацією лінії
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.selectedIndex,
      vsync: this,
    );
  }

  // Цей метод суперважливий!
  // Він змушує лінію поїхати, якщо ти змінив таб не кліком по ньому,
  // а наприклад, натиснув лінк "Create an account" внизу екрану.
  @override
  void didUpdateWidget(covariant KairoTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Обов'язково чистимо пам'ять
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Використовуємо нативний TabBar від Google
        TabBar(
          controller: _tabController,
          onTap: widget.onChanged, // Передаємо клік наверх у твій AuthScreen

          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.only(right: 24.0),

          // Кастомізуємо лінію під твій дизайн
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,

          // Кастомізуємо текст
          labelColor: AppColors.textDark,
          unselectedLabelColor: AppColors.textLight,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),

          // Прибираємо зайві ефекти Material
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),

          // Генеруємо таби з твого масиву рядків
          tabs: widget.tabs.map((tabText) => Tab(text: tabText)).toList(),
        ),
      ],
    );
  }
}
