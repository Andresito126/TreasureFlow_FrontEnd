import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/domain/repositories/map_repository.dart';

class GetCurrentLocationUseCase {
  final MapRepository _repository;
  GetCurrentLocationUseCase(this._repository);

  Future<Place> execute() => _repository.getCurrentLocation();
}