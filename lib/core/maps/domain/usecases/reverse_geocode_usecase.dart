import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/domain/repositories/map_repository.dart';

class ReverseGeocodeUseCase {
  final MapRepository _repository;
  ReverseGeocodeUseCase(this._repository);

  Future<Place> execute(double lat, double lng) =>
      _repository.reverseGeocode(lat, lng);
}
