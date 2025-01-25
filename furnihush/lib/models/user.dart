class User {
  final String name;
  final String email;
  final String? profilePicture;
  final String? address;
  final List<String> paymentMethods;

  User({
    required this.name,
    required this.email,
    this.profilePicture,
    this.address,
    this.paymentMethods = const [],
  });
}
