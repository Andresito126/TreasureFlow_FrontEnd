import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/citizen/domain/usecases/sign_up_citizen_usecase.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_ui_state.dart';

class RegisterCitizenProvider extends ChangeNotifier {
  final SignUpCitizenUseCase _signUpCitizenUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  RegisterCitizenProvider({
    required SignUpCitizenUseCase signUpCitizenUseCase,
    required UploadImageUseCase uploadImageUseCase,
  }) : _signUpCitizenUseCase = signUpCitizenUseCase,
       _uploadImageUseCase = uploadImageUseCase;

  AuthUiState _status = AuthUiState.idle;
  String? _errorMessage;
  File? _selectedImage;

  AuthUiState get status => _status;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String phone,
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
  }) async {
    if (_selectedImage == null) {
      _errorMessage = 'Selecciona una foto de perfil';
      _status = AuthUiState.error;
      notifyListeners();
      return;
    }

    _status = AuthUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final profilePictureUrl = await _uploadImageUseCase(
        imageFile: _selectedImage!,
        folder: 'citizens/profile-pictures',
      );

      await _signUpCitizenUseCase(
        email: email,
        password: password,
        phone: phone,
        firstName: firstName,
        paternalLastName: paternalLastName,
        maternalLastName: maternalLastName,
        profilePictureUrl: profilePictureUrl,
      );

      _status = AuthUiState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthUiState.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = AuthUiState.error;
    }

    notifyListeners();
  }
}
