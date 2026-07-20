import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/storage/token_storage.dart';
import 'package:treasureflow/core/storage/user_storage.dart';

class RoutesApiClientFactory {
  static ApiClient create({
    required TokenStorage tokenStorage,
    required UserStorage userStorage,
  }) {
    return ApiClient(
      tokenStorage: tokenStorage,
      baseUrl: dotenv.env['ROUTES_API_URL'],
      extraHeadersBuilder: () async {
        final userId = await userStorage.getUserId();
        final userType = await userStorage.getUserType();
        return {
          if (userId != null) 'x-user-id': userId,
          if (userType != null) 'x-user-type': userType,
        };
      },
    );
  }
}
