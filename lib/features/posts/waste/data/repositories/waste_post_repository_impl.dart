import 'package:treasureflow/features/posts/waste/data/datasources/waste_post_remote_datasource.dart';
import 'package:treasureflow/features/posts/waste/data/models/create_waste_request_model.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class WastePostRepositoryImpl implements WastePostRepository {
  final WastePostRemoteDatasource _datasource;

  const WastePostRepositoryImpl(this._datasource);

  @override
  Future<String> create({
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
    required List<String> photoUrls,
    required String materialTypeId,
    required String deliveryMode,
    required List<WasteAvailability> schedules,
  }) {
    final model = CreateWasteRequestModel(
      description: description,
      latitude: latitude,
      longitude: longitude,
      addressText: addressText,
      photoUrls: photoUrls,
      materialTypeId: materialTypeId,
      deliveryMode: deliveryMode,
      schedules: schedules,
    );
    return _datasource.create(model);
  }

  @override
  Future<WastePostDetail> getDetail(String id) {
    return _datasource.getDetail(id);
  }
}