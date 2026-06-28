import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:treasureflow/core/media/domain/entities/signed_upload.dart';
import 'package:treasureflow/core/network/api_client.dart';

class MediaRemoteDatasource {
  final ApiClient _apiClient;

  const MediaRemoteDatasource(this._apiClient);

  Future<SignedUpload> getSignature(String folder) async {
    final response = await _apiClient.get('/medias/signature?folder=$folder');
    return SignedUpload.fromJson(response);
  }

  Future<String> uploadToCloudinary({
    required File imageFile,
    required SignedUpload signedUpload,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${signedUpload.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['signature'] = signedUpload.signature
      ..fields['timestamp'] = signedUpload.timestamp.toString()
      ..fields['api_key'] = signedUpload.apiKey
      ..fields['folder'] = signedUpload.folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error al subir imagen a Cloudinary');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }
}
