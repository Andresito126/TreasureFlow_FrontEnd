import 'package:treasureflow/features/establishments/domain/entities/establishment_detail.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_list_item.dart';

abstract class EstablishmentsRepository {
  Future<EstablishmentListPage> list({
    required int limit,
    required int offset,
    double? lat,
    double? lng,
    String? materialTypeId,
    String? search,
    bool? nearby,
  });

  Future<EstablishmentDetail> getDetail(String id);
}
