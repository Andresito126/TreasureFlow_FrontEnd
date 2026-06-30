import 'package:flutter/widgets.dart';
import 'package:treasureflow/core/router/role_based_navigation.dart';

void pushWasteDetail(BuildContext context, String postId) {
  pushByRole(
    context,
    citizenRoute: '/wasteDetail/$postId',
    establishmentRoute: '/wasteDetailLocal/$postId',
  );
}
