import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/local/domain/entities/operating_schedule.dart';
import 'package:treasureflow/features/auth/local/domain/usecases/sign_up_local_usecase.dart';

enum RegisterLocalStatus { idle, loading, success, error }

class RegisterLocalProvider extends ChangeNotifier {
  final SignUpLocalUseCase _signUpLocalUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  RegisterLocalProvider({
    required SignUpLocalUseCase signUpLocalUseCase,
    required UploadImageUseCase uploadImageUseCase,
  })  : _signUpLocalUseCase = signUpLocalUseCase,
        _uploadImageUseCase = uploadImageUseCase;

  RegisterLocalStatus _status = RegisterLocalStatus.idle;
  String? _errorMessage;

  // Step 1
  String _storeName = '';
  String _phone = '';
  String _email = '';
  String _password = '';
  File? _profileImage;
  final List<File> _photos = [];

  // Step 2
  final List<OperatingSchedule> _schedules = [];
  final Set<String> _selectedMaterialIds = {};
  bool _hasVehicle = true;

  // Step 3
  double? _latitude;
  double? _longitude;
  String? _addressText;

  RegisterLocalStatus get status => _status;
  String? get errorMessage => _errorMessage;
  File? get profileImage => _profileImage;
  List<File> get photos => List.unmodifiable(_photos);
  List<OperatingSchedule> get schedules => List.unmodifiable(_schedules);
  Set<String> get selectedMaterialIds => Set.unmodifiable(_selectedMaterialIds);
  bool get hasVehicle => _hasVehicle;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get addressText => _addressText;

  // Step 1 setters
  void setStep1Data({
    required String storeName,
    required String phone,
    required String email,
    required String password,
  }) {
    _storeName = storeName;
    _phone = phone;
    _email = email;
    _password = password;
  }

  void setProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }

  void addPhoto(File photo) {
    if (_photos.length < 3) {
      _photos.add(photo);
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index < _photos.length) {
      _photos.removeAt(index);
      notifyListeners();
    }
  }

  // Step 2 setters
  void setSchedules(List<OperatingSchedule> schedules) {
    _schedules
      ..clear()
      ..addAll(schedules);
  }

  void toggleMaterial(String materialId) {
    if (_selectedMaterialIds.contains(materialId)) {
      _selectedMaterialIds.remove(materialId);
    } else {
      _selectedMaterialIds.add(materialId);
    }
    notifyListeners();
  }

  void setHasVehicle(bool value) {
    _hasVehicle = value;
    notifyListeners();
  }

  // Step 3 setters
  void setLocation({
    required double latitude,
    required double longitude,
    String? addressText,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    _addressText = addressText;
  }

  Future<void> signUp() async {
    if (_profileImage == null) {
      _errorMessage = 'Selecciona una foto de perfil';
      _status = RegisterLocalStatus.error;
      notifyListeners();
      return;
    }

    if (_latitude == null || _longitude == null) {
      _errorMessage = 'Selecciona la ubicación del establecimiento';
      _status = RegisterLocalStatus.error;
      notifyListeners();
      return;
    }

    if (_selectedMaterialIds.isEmpty) {
      _errorMessage = 'Selecciona al menos un material';
      _status = RegisterLocalStatus.error;
      notifyListeners();
      return;
    }

    _status = RegisterLocalStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final profilePictureUrl = await _uploadImageUseCase(
        imageFile: _profileImage!,
        folder: 'establishments/profile-pictures',
      );

      final photoUrls = <String>[];
      for (final photo in _photos) {
        final url = await _uploadImageUseCase(
          imageFile: photo,
          folder: 'establishments/photos',
        );
        photoUrls.add(url);
      }

      await _signUpLocalUseCase(
        email: _email,
        password: _password,
        phone: _phone,
        storeName: _storeName,
        latitude: _latitude!,
        longitude: _longitude!,
        addressText: _addressText,
        hasVehicle: _hasVehicle,
        materialTypeIds: _selectedMaterialIds.toList(),
        schedules: _schedules,
        photoUrls: photoUrls,
        profilePictureUrl: profilePictureUrl,
      );

      _status = RegisterLocalStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = RegisterLocalStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = RegisterLocalStatus.error;
    }

    notifyListeners();
  }
}
