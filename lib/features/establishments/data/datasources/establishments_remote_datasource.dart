import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_detail.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_list_item.dart';
import 'package:treasureflow/shared/utils/material_type_id_catalog.dart';

class EstablishmentsRemoteDatasource {
  final ApiClient _apiClient;

  const EstablishmentsRemoteDatasource(this._apiClient);

  Future<EstablishmentListPage> list({
    required int limit,
    required int offset,
    double? lat,
    double? lng,
    String? materialTypeId,
  }) async {
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (lat != null) 'lat': '$lat',
      if (lng != null) 'lng': '$lng',
      if (materialTypeId != null) 'materialTypeId': materialTypeId,
    };
    final queryString = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await _apiClient.get('/establishments?$queryString');

    return EstablishmentListPage(
      total: response['total'] as int,
      items: (response['items'] as List)
          .map((i) => EstablishmentListItem(
                id: i['id'] as String,
                storeName: i['storeName'] as String,
                photoUrl: i['photoUrl'] as String?,
                addressText: i['addressText'] as String?,
                averageRating: (i['averageRating'] as num).toDouble(),
                materials: (i['materialTypeIds'] as List)
                    .cast<String>()
                    .map(MaterialTypeIdCatalog.nameOf)
                    .toList(),
                isOpen: i['isOpen'] as bool,
                distance: i['distance'] as String?,
                isPremium: i['isPremium'] as bool,
              ))
          .toList(),
    );
  }

  Future<EstablishmentDetail> getDetail(String id) async {
    final response = await _apiClient.get('/establishments/$id');

    return EstablishmentDetail(
      id: response['id'] as String,
      storeName: response['storeName'] as String,
      profilePictureUrl: response['profilePictureUrl'] as String?,
      photoUrls: (response['photoUrls'] as List).cast<String>(),
      addressText: response['addressText'] as String?,
      phone: response['phone'] as String,
      latitude: (response['latitude'] as num).toDouble(),
      longitude: (response['longitude'] as num).toDouble(),
      averageRating: (response['averageRating'] as num).toDouble(),
      materials: (response['materialTypeIds'] as List)
          .cast<String>()
          .map(MaterialTypeIdCatalog.nameOf)
          .toList(),
      hasVehicle: response['hasVehicle'] as bool,
      schedules: (response['schedules'] as List)
          .map((s) => EstablishmentDetailSchedule(
                dayOfWeek: (s['dayOfWeek'] as num).toInt(),
                startTime: s['startTime'] as String,
                endTime: s['endTime'] as String,
              ))
          .toList(),
      isOpen: response['isOpen'] as bool,
    );
  }
}
