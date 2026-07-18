import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treasureflow/core/media/data/datasources/media_remote_datasource.dart';
import 'package:treasureflow/core/media/data/repositories/media_repository_impl.dart';
import 'package:treasureflow/core/media/domain/repositories/media_repository.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/notifications/data/datasources/device_token_remote_datasource.dart';
import 'package:treasureflow/core/notifications/data/repositories/device_token_repository_impl.dart';
import 'package:treasureflow/core/notifications/domain/repositories/device_token_repository.dart';
import 'package:treasureflow/core/notifications/services/notification_service.dart';
import 'package:treasureflow/core/storage/token_storage.dart';
import 'package:treasureflow/core/storage/user_storage.dart';
import 'package:treasureflow/features/auth/citizen/data/datasources/citizen_auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/citizen/data/repositories/citizen_auth_repository_impl.dart';
import 'package:treasureflow/features/auth/citizen/domain/repositories/citizen_auth_repository.dart';
import 'package:treasureflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:treasureflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:treasureflow/features/auth/local/data/datasources/local_auth_remote_datasource.dart';
import 'package:treasureflow/features/collections/citizen/data/datasources/citizen_collections_remote_datasource.dart';
import 'package:treasureflow/features/collections/citizen/data/repositories/citizen_collections_repository_impl.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';
import 'package:treasureflow/features/collections/local/data/datasources/local_collections_remote_datasource.dart';
import 'package:treasureflow/features/collections/local/data/repositories/local_collections_repository_impl.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';
import 'package:treasureflow/features/auth/local/data/repositories/local_auth_repository_impl.dart';
import 'package:treasureflow/features/auth/local/domain/repositories/local_auth_repository.dart';
import 'package:treasureflow/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:treasureflow/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:treasureflow/features/feed/domain/repositories/feed_repository.dart';
import 'package:treasureflow/features/posts/waste/data/datasources/waste_post_remote_datasource.dart';
import 'package:treasureflow/features/posts/waste/data/repositories/waste_post_repository_impl.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';
import 'package:treasureflow/features/profile/data/datasources/my_posts_remote_datasource.dart';
import 'package:treasureflow/features/profile/data/repositories/my_posts_repository_impl.dart';
import 'package:treasureflow/features/profile/domain/repositories/my_posts_repository.dart';

class AppContainer {
  late final TokenStorage tokenStorage;
  late final UserStorage userStorage;
  late final ApiClient apiClient;
  late final ApiClient collectionsApiClient;
  late final CitizenCollectionsRepository citizenCollectionsRepository;
  late final LocalCollectionsRepository localCollectionsRepository;
  late final AuthRepository authRepository;
  late final MediaRepository mediaRepository;
  late final CitizenAuthRepository citizenAuthRepository;
  late final LocalAuthRepository localAuthRepository;
  late final WastePostRepository wastePostRepository;
  late final MyPostsRepository myPostsRepository;
  late final FeedRepository feedRepository;
  late final NotificationService notificationService;
  late final DeviceTokenRepository deviceTokenRepository;

  AppContainer._();

  static Future<AppContainer> create() async {
    await dotenv.load(fileName: '.env');

    final container = AppContainer._();
    await container._init();
    return container;
  }

  Future<void> _init() async {
    tokenStorage = TokenStorage();
    userStorage = UserStorage(tokenStorage);
    apiClient = ApiClient(tokenStorage: tokenStorage);

    // Cliente hacia tf_backend_payments (:3003) — mismo JWT, otra baseUrl
    collectionsApiClient = ApiClient(
      tokenStorage: tokenStorage,
      baseUrl: dotenv.env['COLLECTIONS_API_URL'],
    );
    citizenCollectionsRepository = CitizenCollectionsRepositoryImpl(
      CitizenCollectionsRemoteDatasource(collectionsApiClient),
    );
    localCollectionsRepository = LocalCollectionsRepositoryImpl(
      LocalCollectionsRemoteDatasource(collectionsApiClient),
    );

    final authDatasource = AuthRemoteDatasource(apiClient, tokenStorage, userStorage);
    authRepository = AuthRepositoryImpl(authDatasource);

    final mediaDatasource = MediaRemoteDatasource(apiClient);
    mediaRepository = MediaRepositoryImpl(mediaDatasource);

    final citizenDatasource = CitizenAuthRemoteDatasource(apiClient);
    citizenAuthRepository = CitizenAuthRepositoryImpl(citizenDatasource);

    final localDatasource = LocalAuthRemoteDatasource(apiClient);
    localAuthRepository = LocalAuthRepositoryImpl(localDatasource);

    final wasteDatasource = WastePostRemoteDatasource(apiClient);
    wastePostRepository = WastePostRepositoryImpl(wasteDatasource);

    final myPostsDatasource = MyPostsRemoteDatasource(apiClient);
    myPostsRepository = MyPostsRepositoryImpl(myPostsDatasource);

    final feedDatasource = FeedRemoteDatasource(apiClient);
    feedRepository = FeedRepositoryImpl(feedDatasource);

    notificationService = NotificationService();
    final deviceTokenDatasource = DeviceTokenRemoteDatasource(apiClient);
    deviceTokenRepository = DeviceTokenRepositoryImpl(deviceTokenDatasource);
  }
}
