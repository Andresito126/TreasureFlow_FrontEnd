class CitizenProfile {
  final String fullName;
  final String email;
  final String? profilePictureUrl;
  final double totalEarnings;
  final int totalPublications;
  final int activePublications;

  const CitizenProfile({
    required this.fullName,
    required this.email,
    this.profilePictureUrl,
    required this.totalEarnings,
    required this.totalPublications,
    required this.activePublications,
  });
}

class PostSummary {
  final String id;
  final String publicationType;
  final String? mainPhotoUrl;
  final String status;
  final int offerCount;
  final int viewsCount;
  final String publishedAt;

  const PostSummary({
    required this.id,
    required this.publicationType,
    this.mainPhotoUrl,
    required this.status,
    required this.offerCount,
    required this.viewsCount,
    required this.publishedAt,
  });
}

class PaginatedPosts {
  final CitizenProfile? profile;
  final List<PostSummary> items;
  final String? nextCursor;

  const PaginatedPosts({
    this.profile,
    required this.items,
    this.nextCursor,
  });
}
