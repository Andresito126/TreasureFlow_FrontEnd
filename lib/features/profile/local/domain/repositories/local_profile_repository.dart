import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';

abstract class LocalProfileRepository {
  Future<EstablishmentProfile> getProfile();
}
