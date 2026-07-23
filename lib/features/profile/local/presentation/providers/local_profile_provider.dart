import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/domain/usecases/get_establishment_profile_usecase.dart';
import 'package:treasureflow/features/profile/local/domain/usecases/update_establishment_profile_usecase.dart';
import 'package:treasureflow/features/profile/local/presentation/state/profile_local_ui_state.dart';

export 'package:treasureflow/features/profile/local/presentation/state/profile_local_ui_state.dart'
    show LocalProfileStatus, SaveLocalProfileStatus;

class LocalProfileProvider extends ChangeNotifier {
  final GetEstablishmentProfileUseCase _getEstablishmentProfileUseCase;
  final UpdateEstablishmentProfileUseCase _updateEstablishmentProfileUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  LocalProfileProvider({
    required GetEstablishmentProfileUseCase getEstablishmentProfileUseCase,
    required UpdateEstablishmentProfileUseCase
    updateEstablishmentProfileUseCase,
    required UploadImageUseCase uploadImageUseCase,
  }) : _getEstablishmentProfileUseCase = getEstablishmentProfileUseCase,
       _updateEstablishmentProfileUseCase = updateEstablishmentProfileUseCase,
       _uploadImageUseCase = uploadImageUseCase;

  LocalProfileStatus _status = LocalProfileStatus.idle;
  String? _errorMessage;
  EstablishmentProfile? _profile;
  File? _selectedImage;

  final List<String> _existingPhotoUrls = [];
  final List<File> _newPhotos = [];

  static const _maxPhotos = 3;

  SaveLocalProfileStatus _saveStatus = SaveLocalProfileStatus.idle;
  String? _saveError;

  LocalProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  EstablishmentProfile? get profile => _profile;
  File? get selectedImage => _selectedImage;

  List<String> get existingPhotoUrls => List.unmodifiable(_existingPhotoUrls);
  List<File> get newPhotos => List.unmodifiable(_newPhotos);
  bool get canAddMorePhotos =>
      _existingPhotoUrls.length + _newPhotos.length < _maxPhotos;

  SaveLocalProfileStatus get saveStatus => _saveStatus;
  String? get saveError => _saveError;

  Future<void> load() async {
    _status = LocalProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _getEstablishmentProfileUseCase();
      _existingPhotoUrls
        ..clear()
        ..addAll(_profile!.photoUrls);
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

  void addPhoto(File photo) {
    if (canAddMorePhotos) {
      _newPhotos.add(photo);
      notifyListeners();
    }
  }

  void removeExistingPhoto(int index) {
    if (index < _existingPhotoUrls.length) {
      _existingPhotoUrls.removeAt(index);
      notifyListeners();
    }
  }

  void removeNewPhoto(int index) {
    if (index < _newPhotos.length) {
      _newPhotos.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String storeName,
    required String phone,
    required String addressText,
    required bool hasVehicle,
    List<EstablishmentSchedule>? schedules,
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

      final uploadedPhotoUrls = <String>[];
      for (final photo in _newPhotos) {
        final url = await _uploadImageUseCase(
          imageFile: photo,
          folder: 'establishments/photos',
        );
        uploadedPhotoUrls.add(url);
      }

      await _updateEstablishmentProfileUseCase(
        storeName: storeName,
        phone: phone,
        addressText: addressText,
        hasVehicle: hasVehicle,
        profilePictureUrl: profilePictureUrl,
        schedules: schedules,
        photoUrls: [..._existingPhotoUrls, ...uploadedPhotoUrls],
      );

      _saveStatus = SaveLocalProfileStatus.saved;
      notifyListeners();
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
