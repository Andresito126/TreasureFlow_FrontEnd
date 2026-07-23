class CitizenFullProfile {
  final String email;
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final String phone;
  final String? profilePictureUrl;

  const CitizenFullProfile({
    required this.email,
    required this.firstName,
    required this.paternalLastName,
    required this.maternalLastName,
    required this.phone,
    this.profilePictureUrl,
  });
}
