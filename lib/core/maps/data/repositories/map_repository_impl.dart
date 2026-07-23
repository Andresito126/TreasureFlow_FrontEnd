import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/domain/entities/suggestion.dart';
import 'package:treasureflow/core/maps/domain/repositories/map_repository.dart';
import 'package:treasureflow/core/maps/data/datasources/google_maps_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final GoogleMapsDatasource _datasource;
  MapRepositoryImpl(this._datasource);

  @override
  Future<Place> getCurrentLocation() => _datasource.getCurrentLocation();

  @override
  Future<Place> reverseGeocode(double lat, double lng) =>
      _datasource.reverseGeocode(lat, lng);

  @override
  Future<List<Suggestion>> fetchSuggestions(String input, String sessionToken) =>
      _datasource.fetchSuggestions(input, sessionToken);

  @override
  Future<Place> getPlaceDetail(String placeId, String sessionToken) =>
      _datasource.getPlaceDetail(placeId, sessionToken);
}