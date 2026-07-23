import 'package:treasureflow/features/home/local/domain/entities/local_home_summary.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_summary_repository.dartlocal_home_summary_repository.dart';


class GetLocalHomeSummaryUseCase {
  final LocalHomeSummaryRepository _repository;

  const GetLocalHomeSummaryUseCase(this._repository);

  Future<LocalHomeSummary> call() => _repository.getHome();
}
