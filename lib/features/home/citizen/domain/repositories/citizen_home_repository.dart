import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';

abstract class CitizenHomeRepository {
  Future<CitizenHome> getHome({required double lat, required double lng});
}
