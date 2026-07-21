import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/citizen_full_profile.dart';
import 'package:treasureflow/features/profile/citizen/domain/repositories/citizen_profile_repository.dart';
import 'package:treasureflow/features/profile/citizen/presentation/state/profile_citizen_ui_state.dart';

export 'package:treasureflow/features/profile/citizen/presentation/state/profile_citizen_ui_state.dart'
    show EditCitizenProfileStatus, SaveCitizenProfileStatus;

class EditCitizenProfileProvider extends ChangeNotifier {
  final CitizenProfileRepository _repository;
  final UploadImageUseCase _uploadImageUseCase;

  EditCitizenProfileProvider({
    required CitizenProfileRepository repository,
    required UploadImageUseCase uploadImageUseCase,
  }) : _repository = repository,
       _uploadImageUseCase = uploadImageUseCase;

  EditCitizenProfileStatus _status = EditCitizenProfileStatus.idle;
  String? _errorMessage;
  CitizenFullProfile? _profile;
  File? _selectedImage;

  SaveCitizenProfileStatus _saveStatus = SaveCitizenProfileStatus.idle;
  String? _saveError;

  EditCitizenProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  CitizenFullProfile? get profile => _profile;
  File? get selectedImage => _selectedImage;

  SaveCitizenProfileStatus get saveStatus => _saveStatus;
  String? get saveError => _saveError;

  Future<void> load() async {
    _status = EditCitizenProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      _status = EditCitizenProfileStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = EditCitizenProfileStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = EditCitizenProfileStatus.error;
    }

    notifyListeners();
  }

  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<bool> save({
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
    required String phone,
  }) async {
    _saveStatus = SaveCitizenProfileStatus.saving;
    _saveError = null;
    notifyListeners();

    try {
      String? profilePictureUrl;
      if (_selectedImage != null) {
        profilePictureUrl = await _uploadImageUseCase(
          imageFile: _selectedImage!,
          folder: 'citizens/profile-pictures',
        );
      }

      await _repository.updateProfile(
        firstName: firstName,
        paternalLastName: paternalLastName,
        maternalLastName: maternalLastName,
        phone: phone,
        profilePictureUrl: profilePictureUrl,
      );

      _saveStatus = SaveCitizenProfileStatus.saved;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _saveError = e.message;
      _saveStatus = SaveCitizenProfileStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _saveError = 'Ocurrió un error al guardar tu perfil';
      _saveStatus = SaveCitizenProfileStatus.error;
      notifyListeners();
      return false;
    }
  }
}
