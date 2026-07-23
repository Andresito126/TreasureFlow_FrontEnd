import 'package:treasureflow/features/home/local/domain/entities/local_home_summary.dart';

abstract class LocalHomeSummaryRepository {
  Future<LocalHomeSummary> getHome();
}
