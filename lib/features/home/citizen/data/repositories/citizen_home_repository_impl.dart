import 'package:treasureflow/features/home/citizen/data/datasources/citizen_home_remote_datasource.dart';
import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';
import 'package:treasureflow/features/home/citizen/domain/repositories/citizen_home_repository.dart';

class CitizenHomeRepositoryImpl implements CitizenHomeRepository {
  final CitizenHomeRemoteDatasource _datasource;

  const CitizenHomeRepositoryImpl(this._datasource);

  @override
  Future<CitizenHome> getHome({required double lat, required double lng}) =>
      _datasource.getHome(lat: lat, lng: lng);
}
