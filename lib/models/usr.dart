class User {
  final int ideleve;
  final String? nomeleve;
  final String? prenomeleve;

  User({
    required this.ideleve,
    required this.nomeleve,
    required this.prenomeleve,  
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ideleve: json['ideleve'],
      nomeleve: json['nomeleve'],
      prenomeleve: json['prenomeleve'],      
    );
  }
}