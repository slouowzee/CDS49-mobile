class User {
  final int ideleve;
  final String? nomeleve;
  final String? prenomeleve;
  final String? mail;
  final String? datedenaissance;

  User({
    required this.ideleve,
    required this.nomeleve,
    required this.prenomeleve,
    required this.mail,
    required this.datedenaissance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ideleve: json['ideleve'],
      nomeleve: json['nomeleve'],
      prenomeleve: json['prenomeleve'],     
      mail: json['mail'],
      datedenaissance: json['datedenaissance'],
    );
  }

  get email => mail;
  get dateOfBirth => datedenaissance;
}