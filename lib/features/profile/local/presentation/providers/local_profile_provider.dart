import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/domain/repositories/local_profile_repository.dart';
import 'package:treasureflow/features/profile/local/presentation/state/profile_local_ui_state.dart';

export 'package:treasureflow/features/profile/local/presentation/state/profile_local_ui_state.dart'
    show LocalProfileStatus, SaveLocalProfileStatus;

class LocalProfileProvider extends ChangeNotifier {
  final LocalProfileRepository _repository;
  final UploadImageUseCase _uploadImageUseCase;

  LocalProfileProvider({
    required LocalProfileRepository repository,
    required UploadImageUseCase uploadImageUseCase,
  }) : _repository = repository,
       _uploadImageUseCase = uploadImageUseCase;

  LocalProfileStatus _status = LocalProfileStatus.idle;
  String? _errorMessage;
  EstablishmentProfile? _profile;
  File? _selectedImage;

  SaveLocalProfileStatus _saveStatus = SaveLocalProfileStatus.idle;
  String? _saveError;

  LocalProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  EstablishmentProfile? get profile => _profile;
  File? get selectedImage => _selectedImage;

  SaveLocalProfileStatus get saveStatus => _saveStatus;
  String? get saveError => _saveError;

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

  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String storeName,
    required String phone,
    required String addressText,
    required bool hasVehicle,
  }) async {
    _saveStatus = SaveLocalProfileStatus.saving;
    _saveError = null;
    notifyListeners();

    try {
      String? profilePictureUrl;
      if (_selectedImage != null) {
        profilePictureUrl = await _uploadImageUseCase(
          imageFile: _selectedImage!,
          folder: 'establishments/profile-pictures',
        );
      }

      await _repository.updateProfile(
        storeName: storeName,
        phone: phone,
        addressText: addressText,
        hasVehicle: hasVehicle,
        profilePictureUrl: profilePictureUrl,
      );

      _saveStatus = SaveLocalProfileStatus.saved;
      notifyListeners();
      await load();
      return true;
    } on ApiException catch (e) {
      _saveError = e.message;
      _saveStatus = SaveLocalProfileStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _saveError = 'Ocurrió un error al guardar tu perfil';
      _saveStatus = SaveLocalProfileStatus.error;
      notifyListeners();
      return false;
    }
  }
}
