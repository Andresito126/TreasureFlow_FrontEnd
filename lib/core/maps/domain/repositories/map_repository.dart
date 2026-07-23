import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/domain/entities/suggestion.dart';

abstract class MapRepository {
  Future<Place> getCurrentLocation();
  Future<Place> reverseGeocode(double lat, double lng);
  Future<List<Suggestion>> fetchSuggestions(String input, String sessionToken);
  Future<Place> getPlaceDetail(String placeId, String sessionToken);
}