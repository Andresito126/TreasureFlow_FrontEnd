import 'package:flutter/material.dart';
import 'package:treasureflow/core/auth/user_role.dart';
import 'package:treasureflow/features/feed/presentation/widgets/establishment_feed_tabs_widget.dart';
import 'package:treasureflow/features/feed/presentation/widgets/general_feed_tab_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEstablishment = context.isEstablishment;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Stack(
        children: [
          Positioned.fill(
            child: isEstablishment
                ? const EstablishmentFeedTabsWidget()
                : const GeneralFeedTabWidget(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const FloatingNavBarWidget(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}
