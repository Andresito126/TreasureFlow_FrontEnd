import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/premium/shared/domain/usecases/get_premium_status_usecase.dart';
import 'package:treasureflow/features/premium/shared/domain/usecases/pay_premium_usecase.dart';
import 'package:treasureflow/features/premium/shared/presentation/providers/premium_provider.dart';

class PremiumModule {
  final AppContainer _appContainer;

  PremiumModule(this._appContainer);

  PremiumProvider providePremiumProvider() => PremiumProvider(
        getPremiumStatusUseCase:
            GetPremiumStatusUseCase(_appContainer.premiumRepository),
        payPremiumUseCase: PayPremiumUseCase(_appContainer.premiumRepository),
      );
}
