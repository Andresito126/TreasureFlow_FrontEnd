import 'package:treasureflow/features/establishments/domain/entities/establishment_detail.dart';
import 'package:treasureflow/features/establishments/domain/repositories/establishments_repository.dart';

class GetEstablishmentDetailUseCase {
  final EstablishmentsRepository _repository;

  const GetEstablishmentDetailUseCase(this._repository);

  Future<EstablishmentDetail> call(String id) => _repository.getDetail(id);
}
