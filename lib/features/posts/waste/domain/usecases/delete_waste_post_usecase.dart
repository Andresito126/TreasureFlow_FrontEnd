import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class DeleteWastePostUseCase {
  final WastePostRepository _repository;

  const DeleteWastePostUseCase(this._repository);

  Future<void> call(String postId) => _repository.deletePost(postId);
}
