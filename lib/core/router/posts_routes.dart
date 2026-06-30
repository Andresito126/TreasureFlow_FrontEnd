import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/posts/object/presentation/screens/create_object_screen.dart';
import 'package:treasureflow/features/posts/object/presentation/screens/object_detail_screen.dart';
import 'package:treasureflow/features/posts/waste/presentation/screens/create_waste_screen.dart';
import 'package:treasureflow/features/posts/waste/presentation/screens/waste_detail_local_screen.dart';
import 'package:treasureflow/features/posts/waste/presentation/screens/waste_detail_screen.dart';

final List<GoRoute> postsRoutes = [
  GoRoute(
    path: '/createWaste',
    builder: (context, state) => const CreateWasteScreen(),
  ),
  GoRoute(
    path: '/createObject',
    builder: (context, state) => const CreateObjectScreen(),
  ),
  GoRoute(
    path: '/objectDetail',
    builder: (context, state) => const ObjectDetailScreen(),
  ),
  GoRoute(
    path: '/wasteDetail/:id',
    builder: (context, state) => WasteDetailScreen(postId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/wasteDetailLocal/:id',
    builder: (context, state) => WasteDetailLocalScreen(postId: state.pathParameters['id']!),
  ),
];
