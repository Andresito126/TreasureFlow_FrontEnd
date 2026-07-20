import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/storage/token_storage.dart';

class MainApiClientFactory {
  static ApiClient create(TokenStorage tokenStorage) {
    return ApiClient(
      tokenStorage: tokenStorage,
      baseUrl: dotenv.env['API_URL'],
    );
  }
}
