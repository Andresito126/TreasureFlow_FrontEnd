class Place {
  final double latitude;
  final double longitude;
  final String streetNumber;
  final String street;
  final String city;
  final String zipCode;

  const Place({
    required this.latitude,
    required this.longitude,
    this.streetNumber = '',
    this.street = '',
    this.city = '',
    this.zipCode = '',
  });

  bool get isEmpty => street.isEmpty && city.isEmpty;

  String get line1 {
    if (street.isNotEmpty && streetNumber.isNotEmpty) return '$street $streetNumber';
    if (street.isNotEmpty) return street;
    return 'Dirección desconocida';
  }

  String get line2 {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (zipCode.isNotEmpty) parts.add('CP $zipCode');
    return parts.join(', ');
  }

  String get fullAddress =>
      [line1, if (line2.isNotEmpty) line2].join(', ');
}