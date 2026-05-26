enum SignInMethod { email, google }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.signInMethod,
  });

  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final SignInMethod signInMethod;

  String get displayName => name?.trim().isNotEmpty == true ? name! : email;
}
