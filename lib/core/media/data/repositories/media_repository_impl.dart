import 'dart:io';

import 'package:treasureflow/core/media/data/datasources/media_remote_datasource.dart';
import 'package:treasureflow/core/media/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource _datasource;

  const MediaRepositoryImpl(this._datasource);

  @override
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    final signedUpload = await _datasource.getSignature(folder);
    return _datasource.uploadToCloudinary(
      imageFile: imageFile,
      signedUpload: signedUpload,
    );
  }
}
