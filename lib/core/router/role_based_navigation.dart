import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/core/auth/user_role.dart';

void pushByRole(
  BuildContext context, {
  required String citizenRoute,
  required String establishmentRoute,
}) {
  context.push(context.isEstablishment ? establishmentRoute : citizenRoute);
}

void goByRole(
  BuildContext context, {
  required String citizenRoute,
  required String establishmentRoute,
}) {
  context.go(context.isEstablishment ? establishmentRoute : citizenRoute);
}
