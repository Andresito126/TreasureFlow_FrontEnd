import 'package:treasureflow/features/home/local/data/datasources/local_home_summary_remote_datasource.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_summary.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_summary_repository.dartlocal_home_summary_repository.dart';


class LocalHomeSummaryRepositoryImpl implements LocalHomeSummaryRepository {
  final LocalHomeSummaryRemoteDatasource _datasource;

  const LocalHomeSummaryRepositoryImpl(this._datasource);

  @override
  Future<LocalHomeSummary> getHome() => _datasource.getHome();
}
