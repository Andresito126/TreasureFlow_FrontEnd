import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:treasureflow/core/maps/domain/entities/place.dart';
import '../../domain/entities/suggestion.dart';

class GoogleMapsDatasource {
  final String apiKey;
  final http.Client _client;

  GoogleMapsDatasource({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<Place> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servicio de ubicación desactivado');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return reverseGeocode(position.latitude, position.longitude);
  }

  Future<Place> reverseGeocode(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) {
      return Place(latitude: lat, longitude: lng);
    }
    final p = placemarks.first;
    return Place(
      latitude: lat,
      longitude: lng,
      streetNumber: p.subThoroughfare ?? '',
      street: p.thoroughfare ?? '',
      city: p.locality ?? p.subAdministrativeArea ?? '',
      zipCode: p.postalCode ?? '',
    );
  }

  Future<List<Suggestion>> fetchSuggestions(
      String input, String sessionToken) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&types=address'
      '&language=es'
      '&components=country:mx'
      '&key=$apiKey'
      '&sessiontoken=$sessionToken',
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('fetchSuggestions HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['status'] == 'ZERO_RESULTS') return [];
    if (data['status'] != 'OK') {
      throw Exception(data['error_message'] ?? data['status']);
    }

    return (data['predictions'] as List)
        .map((p) => Suggestion(
              placeId: p['place_id'],
              description: p['description'],
            ))
        .toList();
  }

  Future<Place> getPlaceDetail(
      String placeId, String sessionToken) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=address_component,geometry'
      '&language=es'
      '&key=$apiKey'
      '&sessiontoken=$sessionToken',
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('getPlaceDetail HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      throw Exception(data['error_message'] ?? data['status']);
    }

    final components = data['result']['address_components'] as List;
    String streetNumber = '', street = '', city = '', zipCode = '';

    for (final c in components) {
      final types = c['types'] as List;
      if (types.contains('street_number')) streetNumber = c['long_name'];
      if (types.contains('route')) street = c['long_name'];
      if (types.contains('locality')) city = c['long_name'];
      if (types.contains('postal_code')) zipCode = c['long_name'];
    }

    final loc = data['result']['geometry']['location'];
    return Place(
      latitude: (loc['lat'] as num).toDouble(),
      longitude: (loc['lng'] as num).toDouble(),
      streetNumber: streetNumber,
      street: street,
      city: city,
      zipCode: zipCode,
    );
  }
}