import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class GetWastePostDetailUseCase {
  final WastePostRepository _repository;

  const GetWastePostDetailUseCase(this._repository);

  Future<WastePostDetail> call(String id) {
    return _repository.getDetail(id);
  }
}
