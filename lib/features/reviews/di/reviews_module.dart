import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:treasureflow/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:treasureflow/features/reviews/domain/usecases/delete_review_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/get_review_eligibility_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/list_establishment_reviews_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/list_my_reviews_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/submit_review_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/update_review_usecase.dart';
import 'package:treasureflow/features/reviews/presentation/providers/establishment_reviews_provider.dart';
import 'package:treasureflow/features/reviews/presentation/providers/submit_review_provider.dart';

class ReviewsModule {
  final AppContainer _appContainer;

  ReviewsModule(this._appContainer);

  ReviewsRepository _provideRepository() {
    final datasource = ReviewsRemoteDatasource(_appContainer.apiClient);
    return ReviewsRepositoryImpl(datasource);
  }

  ListEstablishmentReviewsUseCase _provideListEstablishmentReviewsUseCase() =>
      ListEstablishmentReviewsUseCase(_provideRepository());

  ListMyReviewsUseCase _provideListMyReviewsUseCase() =>
      ListMyReviewsUseCase(_provideRepository());

  GetReviewEligibilityUseCase _provideGetReviewEligibilityUseCase() =>
      GetReviewEligibilityUseCase(_provideRepository());

  SubmitReviewUseCase _provideSubmitReviewUseCase() =>
      SubmitReviewUseCase(_provideRepository());

  UpdateReviewUseCase _provideUpdateReviewUseCase() =>
      UpdateReviewUseCase(_provideRepository());

  DeleteReviewUseCase _provideDeleteReviewUseCase() =>
      DeleteReviewUseCase(_provideRepository());

  EstablishmentReviewsProvider provideReviewsProvider({String? establishmentId}) =>
      EstablishmentReviewsProvider(
        listEstablishmentReviewsUseCase: _provideListEstablishmentReviewsUseCase(),
        listMyReviewsUseCase: _provideListMyReviewsUseCase(),
        updateReviewUseCase: _provideUpdateReviewUseCase(),
        deleteReviewUseCase: _provideDeleteReviewUseCase(),
        establishmentId: establishmentId,
      );

  SubmitReviewProvider provideSubmitReviewProvider() => SubmitReviewProvider(
    getReviewEligibilityUseCase: _provideGetReviewEligibilityUseCase(),
    submitReviewUseCase: _provideSubmitReviewUseCase(),
  );
}
