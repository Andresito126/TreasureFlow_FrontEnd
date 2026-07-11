import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/sales/presentation/screens/my_sales_screen.dart';
import 'package:treasureflow/features/sales/presentation/screens/sale_detail_screen.dart';

final List<GoRoute> salesRoutes = [
  GoRoute(
    path: '/mySales',
    builder: (context, state) => const MySalesScreen(),
  ),
  GoRoute(
    path: '/saleDetail/:id',
    builder: (context, state) =>
        SaleDetailScreen(saleId: state.pathParameters['id']!),
  ),
];
