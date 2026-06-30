import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/create_waste_post_usecase.dart';

enum CreateWasteStatus { idle, loading, success, error }

class CreateWasteProvider extends ChangeNotifier {
  final CreateWastePostUseCase _createWastePostUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  CreateWasteProvider({
    required CreateWastePostUseCase createWastePostUseCase,
    required UploadImageUseCase uploadImageUseCase,
  })  : _createWastePostUseCase = createWastePostUseCase,
        _uploadImageUseCase = uploadImageUseCase;

  CreateWasteStatus _status = CreateWasteStatus.idle;
  String? _errorMessage;
  String? _createdPostId;

  String? _materialTypeId;
  String? _description;
  String _deliveryMode = 'drop_off';
  final List<File> _photos = [];
  final List<WasteAvailability> _schedules = [];
  double? _latitude;
  double? _longitude;
  String? _addressText;

  CreateWasteStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get createdPostId => _createdPostId;
  String? get materialTypeId => _materialTypeId;
  String get deliveryMode => _deliveryMode;
  List<File> get photos => List.unmodifiable(_photos);

  void setMaterialTypeId(String? id) {
    _materialTypeId = id;
    notifyListeners();
  }

  void setDescription(String description) {
    _description = description;
  }

  void setDeliveryMode(String mode) {
    _deliveryMode = mode;
    if (mode != 'home_delivery') {
      _schedules.clear();
    }
    notifyListeners();
  }

  void setSchedules(List<WasteAvailability> schedules) {
    _schedules
      ..clear()
      ..addAll(schedules);
  }

  void setLocation({
    required double latitude,
    required double longitude,
    required String addressText,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    _addressText = addressText;
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

  Future<void> submit() async {
    if (_materialTypeId == null) {
      _setError('Selecciona un material');
      return;
    }
    if (_description == null || _description!.trim().isEmpty) {
      _setError('Agrega una descripción');
      return;
    }
    if (_latitude == null || _longitude == null || _addressText == null) {
      _setError('Selecciona una ubicación');
      return;
    }
    if (_deliveryMode == 'home_delivery' && _schedules.isEmpty) {
      _setError('Agrega al menos un horario de disponibilidad');
      return;
    }

    _status = CreateWasteStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final photoUrls = <String>[];
      for (final photo in _photos) {
        final url = await _uploadImageUseCase(
          imageFile: photo,
          folder: 'publications/waste-photos',
        );
        photoUrls.add(url);
      }

      _createdPostId = await _createWastePostUseCase(
        description: _description!.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        addressText: _addressText!,
        photoUrls: photoUrls,
        materialTypeId: _materialTypeId!,
        deliveryMode: _deliveryMode,
        schedules: _deliveryMode == 'home_delivery' ? _schedules : [],
      );

      _status = CreateWasteStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CreateWasteStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = CreateWasteStatus.error;
    }

    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = CreateWasteStatus.error;
    notifyListeners();
  }

  void reset() {
    _status = CreateWasteStatus.idle;
    _errorMessage = null;
    _createdPostId = null;
    _materialTypeId = null;
    _description = null;
    _deliveryMode = 'drop_off';
    _photos.clear();
    _schedules.clear();
    _latitude = null;
    _longitude = null;
    _addressText = null;
    notifyListeners();
  }
}