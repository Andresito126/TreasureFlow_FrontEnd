import 'package:flutter/material.dart';
import 'package:treasureflow/features/feed/presentation/widgets/general_feed_tab_widget.dart';
import 'package:treasureflow/features/feed/presentation/widgets/recommended_feed_tab_widget.dart';

class EstablishmentFeedTabsWidget extends StatefulWidget {
  const EstablishmentFeedTabsWidget({super.key});

  @override
  State<EstablishmentFeedTabsWidget> createState() =>
      _EstablishmentFeedTabsWidgetState();
}

class _EstablishmentFeedTabsWidgetState
    extends State<EstablishmentFeedTabsWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurface.withValues(alpha: 0.5),
            indicatorColor: colors.primary,
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Recomendado para ti'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                GeneralFeedTabWidget(),
                RecommendedFeedTabWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
