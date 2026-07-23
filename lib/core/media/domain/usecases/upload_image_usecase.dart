import 'dart:io';

import 'package:treasureflow/core/media/domain/repositories/media_repository.dart';

class UploadImageUseCase {
  final MediaRepository _repository;

  const UploadImageUseCase(this._repository);

  Future<String> call({
    required File imageFile,
    required String folder,
  }) {
    return _repository.uploadImage(imageFile: imageFile, folder: folder);
  }
}