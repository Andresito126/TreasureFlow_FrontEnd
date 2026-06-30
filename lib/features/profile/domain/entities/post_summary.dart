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
  final List<PostSummary> items;
  final String? nextCursor;

  const PaginatedPosts({
    required this.items,
    this.nextCursor,
  });
}
