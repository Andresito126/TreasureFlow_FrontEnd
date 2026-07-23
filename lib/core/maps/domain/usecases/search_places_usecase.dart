import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/domain/repositories/map_repository.dart';
import '../entities/suggestion.dart';

class SearchPlacesUseCase {
  final MapRepository _repository;
  SearchPlacesUseCase(this._repository);

  Future<List<Suggestion>> fetchSuggestions(
    String input,
    String sessionToken,
  ) => _repository.fetchSuggestions(input, sessionToken);

  Future<Place> getPlaceDetail(String placeId, String sessionToken) =>
      _repository.getPlaceDetail(placeId, sessionToken);
}
