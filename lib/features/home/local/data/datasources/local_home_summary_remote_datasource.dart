import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_summary.dart';

class LocalHomeSummaryRemoteDatasource {
  final ApiClient _apiClient;

  const LocalHomeSummaryRemoteDatasource(this._apiClient);

  Future<LocalHomeSummary> getHome() async {
    final response = await _apiClient.get('/home');

    return LocalHomeSummary(
      storeName: response['storeName'] as String,
      profilePictureUrl: response['profilePictureUrl'] as String,
      isPremium: response['isPremium'] as bool? ?? false,
      photoUrls: (response['photoUrls'] as List).cast<String>(),
      averageRating: (response['averageRating'] as num).toDouble(),
      materials: (response['materials'] as List).cast<String>(),
      schedules: (response['schedules'] as List)
          .map(
            (s) => LocalHomeSchedule(
              dayOfWeek: s['dayOfWeek'] as int,
              dayLabel: s['dayLabel'] as String,
              startTime: s['startTime'] as String,
              endTime: s['endTime'] as String,
            ),
          )
          .toList(),
      upcomingPickups: (response['upcomingPickups'] as List)
          .map(
            (u) => UpcomingPickupDay(
              date: u['date'] as String,
              dayLabel: u['dayLabel'] as String,
              count: u['count'] as int,
            ),
          )
          .toList(),
      pendingOffers: (response['pendingOffers'] as List)
          .map(
            (o) => LocalPendingOffer(
              offerId: o['offerId'] as String,
              publicationId: o['publicationId'] as String,
              publicationPhotoUrl: o['publicationPhotoUrl'] as String,
              publicationMaterial: o['publicationMaterial'] as String,
              citizenId: o['citizenId'] as String,
              citizenName: o['citizenName'] as String,
              pricePerUnit: (o['pricePerUnit'] as num).toDouble(),
              unit: o['unit'] as String,
              offeredAt: o['offeredAt'] as String,
            ),
          )
          .toList(),
      pendingOffersCount: response['pendingOffersCount'] as int,
      monthlySpend: (response['monthlySpend'] as num).toDouble(),
      monthlyCompletedPickups: response['monthlyCompletedPickups'] as int,
    );
  }
}
