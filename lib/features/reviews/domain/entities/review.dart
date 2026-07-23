class Review {
  final String id;
  final String citizenId;
  final String citizenName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}

class ReviewsPage {
  final int total;
  final List<Review> items;

  const ReviewsPage({required this.total, required this.items});
}

class EligibleCollection {
  final String collectionId;
  final String wasteTitle;

  const EligibleCollection({required this.collectionId, required this.wasteTitle});
}
