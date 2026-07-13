import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class GetAvailableSlotsUseCase {
  final WastePostRepository _repository;

  const GetAvailableSlotsUseCase(this._repository);

  Future<List<AvailableSlot>> call(String establishmentId) {
    return _repository.getAvailableSlots(establishmentId);
  }
}
