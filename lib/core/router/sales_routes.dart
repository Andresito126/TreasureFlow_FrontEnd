import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/citizen/di/citizen_collections_module.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/citizen/presentation/screens/collection_detail_citizen_screen.dart';
import 'package:treasureflow/features/collections/local/di/local_collections_module.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/local/presentation/screens/collection_detail_local_screen.dart';
import 'package:treasureflow/features/reviews/di/reviews_module.dart';
import 'package:treasureflow/features/reviews/presentation/providers/submit_review_provider.dart';
import 'package:treasureflow/features/sales/citizen/presentation/screens/my_sales_screen.dart';
import 'package:treasureflow/features/sales/local/presentation/screens/collection_route_screen.dart';
import 'package:treasureflow/features/sales/local/presentation/screens/my_purchases_screen.dart';
import 'package:treasureflow/features/tracking/citizen/di/tracking_module.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/providers/citizen_tracking_entry_provider.dart';

final List<GoRoute> salesRoutes = [
  //  Ciudadano
  GoRoute(
    path: '/mySales',
    builder: (context, state) => const MySalesScreen(),
  ),
  GoRoute(
    path: '/saleDetail/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final container = context.read<AppContainer>();
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CitizenCollectionDetailProvider>(
            create: (_) => CitizenCollectionsModule(container)
                .provideDetailProvider()
              ..load(id),
          ),
          ChangeNotifierProvider<CitizenTrackingEntryProvider>(
            create: (_) => TrackingModule(container)
                .provideTrackingEntryProvider()
              ..check(),
          ),
          ChangeNotifierProvider<SubmitReviewProvider>(
            create: (_) => ReviewsModule(container).provideSubmitReviewProvider(),
          ),
        ],
        child: CollectionDetailCitizenScreen(collectionId: id),
      );
    },
  ),

  //  Establecimiento
  GoRoute(
    path: '/myPurchases',
    builder: (context, state) => const MyPurchasesScreen(),
  ),
  GoRoute(
    path: '/collectionRoute',
    builder: (context, state) => const CollectionRouteScreen(),
  ),
  GoRoute(
    path: '/purchaseDetail/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final container = context.read<AppContainer>();
      return ChangeNotifierProvider<LocalCollectionDetailProvider>(
        create: (_) =>
            LocalCollectionsModule(container).provideDetailProvider()
              ..load(id),
        child: CollectionDetailLocalScreen(collectionId: id),
      );
    },
  ),
];
