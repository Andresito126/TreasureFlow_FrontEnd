class LocalHomeSchedule {
  final int dayOfWeek;
  final String dayLabel;
  final String startTime;
  final String endTime;

  const LocalHomeSchedule({
    required this.dayOfWeek,
    required this.dayLabel,
    required this.startTime,
    required this.endTime,
  });
}

class UpcomingPickupDay {
  final String date;
  final String dayLabel;
  final int count;

  const UpcomingPickupDay({
    required this.date,
    required this.dayLabel,
    required this.count,
  });
}

class LocalPendingOffer {
  final String offerId;
  final String publicationId;
  final String publicationPhotoUrl;
  final String publicationMaterial;
  final String citizenId;
  final String citizenName;
  final double pricePerUnit;
  final String unit;
  final String offeredAt;

  const LocalPendingOffer({
    required this.offerId,
    required this.publicationId,
    required this.publicationPhotoUrl,
    required this.publicationMaterial,
    required this.citizenId,
    required this.citizenName,
    required this.pricePerUnit,
    required this.unit,
    required this.offeredAt,
  });
}

class LocalHomeSummary {
  final String storeName;
  final String profilePictureUrl;
  final bool isPremium;
  final List<String> photoUrls;
  final double averageRating;
  final List<String> materials;
  final List<LocalHomeSchedule> schedules;
  final List<UpcomingPickupDay> upcomingPickups;
  final List<LocalPendingOffer> pendingOffers;
  final int pendingOffersCount;
  final double monthlySpend;
  final int monthlyCompletedPickups;

  const LocalHomeSummary({
    required this.storeName,
    required this.profilePictureUrl,
    required this.isPremium,
    required this.photoUrls,
    required this.averageRating,
    required this.materials,
    required this.schedules,
    required this.upcomingPickups,
    required this.pendingOffers,
    required this.pendingOffersCount,
    required this.monthlySpend,
    required this.monthlyCompletedPickups,
  });
}
