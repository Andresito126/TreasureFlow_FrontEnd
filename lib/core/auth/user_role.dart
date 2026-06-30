import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';

enum UserRole {
  citizen,
  establishment;

  static UserRole fromUserType(String? userType) {
    return userType == 'establishment' ? UserRole.establishment : UserRole.citizen;
  }
}

extension UserRoleX on BuildContext {
  UserRole get userRole => UserRole.fromUserType(read<AuthProvider>().userType);

  bool get isEstablishment => userRole == UserRole.establishment;

  bool get isCitizen => userRole == UserRole.citizen;
}
