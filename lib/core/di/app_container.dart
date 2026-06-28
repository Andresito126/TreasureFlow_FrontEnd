import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treasureflow/core/media/data/datasources/media_remote_datasource.dart';
import 'package:treasureflow/core/media/data/repositories/media_repository_impl.dart';
import 'package:treasureflow/core/media/domain/repositories/media_repository.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/storage/token_storage.dart';
import 'package:treasureflow/core/storage/user_storage.dart';
import 'package:treasureflow/features/auth/citizen/data/datasources/citizen_auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/citizen/data/repositories/citizen_auth_repository_impl.dart';
import 'package:treasureflow/features/auth/citizen/domain/repositories/citizen_auth_repository.dart';
import 'package:treasureflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:treasureflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:treasureflow/features/auth/local/data/datasources/local_auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/local/data/repositories/local_auth_repository_impl.dart';
import 'package:treasureflow/features/auth/local/domain/repositories/local_auth_repository.dart';

class AppContainer {
  late final TokenStorage tokenStorage;
  late final UserStorage userStorage;
  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final MediaRepository mediaRepository;
  late final CitizenAuthRepository citizenAuthRepository;
  late final LocalAuthRepository localAuthRepository;

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

    final authDatasource = AuthRemoteDatasource(apiClient, tokenStorage);
    authRepository = AuthRepositoryImpl(authDatasource);

    final mediaDatasource = MediaRemoteDatasource(apiClient);
    mediaRepository = MediaRepositoryImpl(mediaDatasource);

    final citizenDatasource = CitizenAuthRemoteDatasource(apiClient);
    citizenAuthRepository = CitizenAuthRepositoryImpl(citizenDatasource);

    final localDatasource = LocalAuthRemoteDatasource(apiClient);
    localAuthRepository = LocalAuthRepositoryImpl(localDatasource);
  }
}
