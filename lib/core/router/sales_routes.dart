import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/collections/citizen/presentation/screens/collection_detail_citizen_screen.dart';
import 'package:treasureflow/features/collections/local/presentation/screens/collection_detail_local_screen.dart';
import 'package:treasureflow/features/sales/citizen/presentation/screens/my_sales_screen.dart';
import 'package:treasureflow/features/sales/local/presentation/screens/collection_route_screen.dart';
import 'package:treasureflow/features/sales/local/presentation/screens/my_purchases_screen.dart';

final List<GoRoute> salesRoutes = [
  //  Ciudadano
  GoRoute(
    path: '/mySales',
    builder: (context, state) => const MySalesScreen(),
  ),
  GoRoute(
    path: '/saleDetail/:id',
    builder: (context, state) => CollectionDetailCitizenScreen(
      collectionId: state.pathParameters['id']!,
    ),
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
    builder: (context, state) => CollectionDetailLocalScreen(
      collectionId: state.pathParameters['id']!,
    ),
  ),
];
