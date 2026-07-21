import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/domain/repositories/local_profile_repository.dart';
import 'package:treasureflow/features/profile/local/presentation/state/profile_local_ui_state.dart';

export 'package:treasureflow/features/profile/local/presentation/state/profile_local_ui_state.dart'
    show LocalProfileStatus;

class LocalProfileProvider extends ChangeNotifier {
  final LocalProfileRepository _repository;

  LocalProfileProvider({required LocalProfileRepository repository})
      : _repository = repository;

  LocalProfileStatus _status = LocalProfileStatus.idle;
  String? _errorMessage;
  EstablishmentProfile? _profile;

  LocalProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  EstablishmentProfile? get profile => _profile;

  Future<void> load() async {
    _status = LocalProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      _status = LocalProfileStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = LocalProfileStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = LocalProfileStatus.error;
    }

    notifyListeners();
  }
}
