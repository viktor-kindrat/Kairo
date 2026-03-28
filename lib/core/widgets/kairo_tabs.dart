import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

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

class _KairoTabsState extends State<KairoTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.selectedIndex,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant KairoTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          onTap: widget.onChanged,

          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.only(right: context.sp(24)),

          indicatorColor: AppColors.primary,
          indicatorWeight: context.sp(3),
          indicatorSize: TabBarIndicatorSize.label,

          labelColor: AppColors.textDark,
          unselectedLabelColor: AppColors.textLight,
          labelStyle: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w500,
          ),

          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),

          tabs: widget.tabs.map((tabText) => Tab(text: tabText)).toList(),
        ),
      ],
    );
  }
}
