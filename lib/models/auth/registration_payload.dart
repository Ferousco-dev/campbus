class RegistrationPayload {
  final String fullName;
  final String matricNumber;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;

  const RegistrationPayload({
    required this.fullName,
    required this.matricNumber,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'matricNumber': matricNumber,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }
}
