import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:treasureflow/core/storage/user_storage.dart';

class TrackingSocketClientFactory {
  final UserStorage _userStorage;

  const TrackingSocketClientFactory(this._userStorage);

  Future<io.Socket> create() async {
    final userId = await _userStorage.getUserId();
    final userType = await _userStorage.getUserType();

    final socket = io.io(
      _trackingUrl(),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            if (userId != null) 'x-user-id': userId,
            if (userType != null) 'x-user-type': userType,
          })
          .build(),
    );
    return socket;
  }

  String _trackingUrl() {
    final routesApiUrl = dotenv.env['ROUTES_API_URL']!;
    final uri = Uri.parse(routesApiUrl);
    final origin = '${uri.scheme}://${uri.host}:${uri.port}';
    return '$origin/tracking';
  }
}
