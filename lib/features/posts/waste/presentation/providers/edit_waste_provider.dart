import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/update_waste_post_usecase.dart';

enum EditWasteStatus { idle, loading, success, error }

class PhotoSlot {
  final String? url;
  final File? file;

  const PhotoSlot.fromUrl(this.url) : file = null;
  const PhotoSlot.fromFile(this.file) : url = null;

  bool get isExisting => url != null;
}

class EditWasteProvider extends ChangeNotifier {
  final UpdateWastePostUseCase _updateUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  EditWasteProvider({
    required UpdateWastePostUseCase updateUseCase,
    required UploadImageUseCase uploadImageUseCase,
  }) : _updateUseCase = updateUseCase,
       _uploadImageUseCase = uploadImageUseCase;

  EditWasteStatus _status = EditWasteStatus.idle;
  String? _errorMessage;

  String? _materialTypeId;
  String _description = '';
  String _deliveryMode = 'drop_off';
  final List<PhotoSlot> _photos = [];
  double? _latitude;
  double? _longitude;
  String? _addressText;

  EditWasteStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get materialTypeId => _materialTypeId;
  String get description => _description;
  String get deliveryMode => _deliveryMode;
  List<PhotoSlot> get photos => List.unmodifiable(_photos);
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get addressText => _addressText;

  void initializeFromDetail(WastePostDetail detail) {
    _materialTypeId = detail.materialTypeId;
    _description = detail.description;
    _deliveryMode = detail.deliveryMode;
    _photos
      ..clear()
      ..addAll(detail.photoUrls.map((url) => PhotoSlot.fromUrl(url)));
    _latitude = detail.latitude;
    _longitude = detail.longitude;
    _addressText = detail.addressText;
    _status = EditWasteStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void setMaterialTypeId(String? id) {
    _materialTypeId = id;
    notifyListeners();
  }

  void setDescription(String text) {
    _description = text;
  }

  void setDeliveryMode(String mode) {
    _deliveryMode = mode;
    notifyListeners();
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
      _photos.add(PhotoSlot.fromFile(photo));
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index < _photos.length) {
      _photos.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> submit(String postId) async {
    if (_materialTypeId == null) {
      _setError('Selecciona un material');
      return;
    }
    if (_description.trim().isEmpty) {
      _setError('Agrega una descripción');
      return;
    }
    if (_latitude == null || _longitude == null || _addressText == null) {
      _setError('Selecciona una ubicación');
      return;
    }

    _status = EditWasteStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final photoUrls = <String>[];
      for (final slot in _photos) {
        if (slot.isExisting) {
          photoUrls.add(slot.url!);
        } else {
          final url = await _uploadImageUseCase(
            imageFile: slot.file!,
            folder: 'publications/waste-photos',
          );
          photoUrls.add(url);
        }
      }

      await _updateUseCase(
        postId: postId,
        description: _description.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        addressText: _addressText!,
        photoUrls: photoUrls,
        materialTypeId: _materialTypeId!,
        deliveryMode: _deliveryMode,
      );

      _status = EditWasteStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = EditWasteStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = EditWasteStatus.error;
    }

    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = EditWasteStatus.error;
    notifyListeners();
  }
}
