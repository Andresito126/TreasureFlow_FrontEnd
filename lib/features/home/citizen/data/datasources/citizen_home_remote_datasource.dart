import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';
import 'package:treasureflow/shared/utils/material_type_translator.dart';

class CitizenHomeRemoteDatasource {
  final ApiClient _apiClient;

  const CitizenHomeRemoteDatasource(this._apiClient);

  Future<CitizenHome> getHome({required double lat, required double lng}) async {
    final response = await _apiClient.get('/home?lat=$lat&lng=$lng');

    return CitizenHome(
      fullName: response['fullName'] as String,
      profilePictureUrl: response['profilePictureUrl'] as String?,
      isPremium: response['isPremium'] as bool,
      monthlyEarnings: (response['monthlyEarnings'] as num).toDouble(),
      totalPublications: response['totalPublications'] as int,
      itemsObtained: response['itemsObtained'] as int,
      nearbyEstablishments: (response['nearbyEstablishments'] as List)
          .map((e) => NearbyEstablishment(
                id: e['id'] as String,
                storeName: e['storeName'] as String,
                photoUrl: e['photoUrl'] as String?,
                distance: e['distance'] as String,
                averageRating: (e['averageRating'] as num).toDouble(),
                reviewsCount: (e['reviewsCount'] as num?)?.toInt() ?? 0,
                materials: (e['materials'] as List)
                    .cast<String>()
                    .map(MaterialTypeTranslator.translate)
                    .toList(),
                isOpen: e['isOpen'] as bool,
                isPremium: e['isPremium'] as bool,
              ))
          .toList(),
      nearbyItems: (response['nearbyItems'] as List)
          .map((i) => NearbyItem(
                id: i['id'] as String,
                mainPhotoUrl: i['mainPhotoUrl'] as String?,
                description: i['description'] as String,
                distance: i['distance'] as String,
                publishedAt: i['publishedAt'] as String,
              ))
          .toList(),
      receivedOffers: (response['receivedOffers'] as List)
          .map((o) => ReceivedOffer(
                offerId: o['offerId'] as String,
                publicationId: o['publicationId'] as String,
                publicationPhotoUrl: o['publicationPhotoUrl'] as String?,
                establishmentName: o['establishmentName'] as String,
                pricePerUnit: (o['pricePerUnit'] as num).toDouble(),
                unit: o['unit'] as String,
                offeredAt: o['offeredAt'] as String,
              ))
          .toList(),
    );
  }
}
