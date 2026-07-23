import 'package:treasureflow/features/establishments/data/datasources/establishments_remote_datasource.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_detail.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_list_item.dart';
import 'package:treasureflow/features/establishments/domain/repositories/establishments_repository.dart';

class EstablishmentsRepositoryImpl implements EstablishmentsRepository {
  final EstablishmentsRemoteDatasource _datasource;

  const EstablishmentsRepositoryImpl(this._datasource);

  @override
  Future<EstablishmentListPage> list({
    required int limit,
    required int offset,
    double? lat,
    double? lng,
  }) {
    return _datasource.list(limit: limit, offset: offset, lat: lat, lng: lng);
  }

  @override
  Future<EstablishmentDetail> getDetail(String id) => _datasource.getDetail(id);
}
