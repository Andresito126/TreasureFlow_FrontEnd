import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/storage/token_storage.dart';

class PaymentsApiClientFactory {
  static ApiClient create(TokenStorage tokenStorage) {
    return ApiClient(
      tokenStorage: tokenStorage,
      baseUrl: dotenv.env['COLLECTIONS_API_URL'],
    );
  }
}
