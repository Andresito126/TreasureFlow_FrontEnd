import 'package:treasureflow/features/establishments/domain/entities/establishment_list_item.dart';
import 'package:treasureflow/features/establishments/domain/repositories/establishments_repository.dart';

class ListEstablishmentsUseCase {
  final EstablishmentsRepository _repository;

  const ListEstablishmentsUseCase(this._repository);

  Future<EstablishmentListPage> call({
    required int limit,
    required int offset,
    double? lat,
    double? lng,
    String? materialTypeId,
  }) {
    return _repository.list(
      limit: limit,
      offset: offset,
      lat: lat,
      lng: lng,
      materialTypeId: materialTypeId,
    );
  }
}
