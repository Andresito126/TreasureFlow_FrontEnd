import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';
import 'package:treasureflow/features/home/citizen/domain/repositories/citizen_home_repository.dart';

class GetCitizenHomeUseCase {
  final CitizenHomeRepository _repository;

  const GetCitizenHomeUseCase(this._repository);

  Future<CitizenHome> call({required double lat, required double lng}) {
    return _repository.getHome(lat: lat, lng: lng);
  }
}
