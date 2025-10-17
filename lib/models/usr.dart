class User {
  final int ideleve;
  final String? nomeleve;
  final String? prenomeleve;
  final String? emaileleve;
  final String? datenaissanceeleve;

  User({
    required this.ideleve,
    required this.nomeleve,
    required this.prenomeleve,
    required this.emaileleve,
    required this.datenaissanceeleve,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ideleve: json['ideleve'],
      nomeleve: json['nomeleve'],
      prenomeleve: json['prenomeleve'],     
      emaileleve: json['emaileleve'] ?? json['mail'], // Fallback pour compatibilité
      datenaissanceeleve: json['datenaissanceeleve'] ?? json['datedenaissance'], // Fallback pour compatibilité
    );
  }

  // Getters pour compatibilité avec l'ancien code
  get mail => emaileleve;
  get email => emaileleve;
  get datedenaissance => datenaissanceeleve;
  get dateOfBirth => datenaissanceeleve;
}