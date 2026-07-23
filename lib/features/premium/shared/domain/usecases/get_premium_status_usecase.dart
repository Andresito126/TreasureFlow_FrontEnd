import 'package:treasureflow/features/premium/shared/domain/entities/premium_status.dart';
import 'package:treasureflow/features/premium/shared/domain/repositories/premium_repository.dart';

class GetPremiumStatusUseCase {
  final PremiumRepository _repository;

  const GetPremiumStatusUseCase(this._repository);

  Future<PremiumStatus> call() => _repository.getStatus();
}
