class CitizenRegisterRequestModel {
  final String email;
  final String password;
  final String phone;
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final String profilePictureUrl;

  const CitizenRegisterRequestModel({
    required this.email,
    required this.password,
    required this.phone,
    required this.firstName,
    required this.paternalLastName,
    required this.maternalLastName,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'phone': phone,
        'firstName': firstName,
        'paternalLastName': paternalLastName,
        'maternalLastName': maternalLastName,
        'profilePictureUrl': profilePictureUrl,
      };
}
