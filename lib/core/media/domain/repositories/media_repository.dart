import 'dart:io';

abstract class MediaRepository {
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
  });
}