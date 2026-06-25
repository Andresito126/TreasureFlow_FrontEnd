// core/maps/di/map_module.dart
import 'package:treasureflow/core/maps/data/datasources/google_maps_datasource.dart';
import 'package:treasureflow/core/maps/data/repositories/map_repository_impl.dart';
import 'package:treasureflow/core/maps/domain/usecases/get_current_location_usecase.dart';
import 'package:treasureflow/core/maps/domain/usecases/reverse_geocode_usecase.dart';
import 'package:treasureflow/core/maps/domain/usecases/search_places_usecase.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';

class MapModule {
  static const apiKey = '';

  static MapProvider createProvider() {
    final datasource = GoogleMapsDatasource(apiKey: apiKey);
    final repository = MapRepositoryImpl(datasource);

    return MapProvider(
      getCurrentLocation: GetCurrentLocationUseCase(repository),
      reverseGeocode: ReverseGeocodeUseCase(repository),
      searchPlaces: SearchPlacesUseCase(repository),
    );
  }
}