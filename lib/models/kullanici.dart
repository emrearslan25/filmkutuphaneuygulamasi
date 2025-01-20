import 'package:firebase_auth/firebase_auth.dart' as auth;

class Kullanici {
  final String uid;
  final String email;
  final bool adminMi;

  Kullanici({
    required this.uid,
    required this.email,
    this.adminMi = false,
  });

  factory Kullanici.fromFirebaseUser(auth.User user, {bool adminMi = false}) {
    return Kullanici(
      uid: user.uid,
      email: user.email ?? '',
      adminMi: adminMi,
    );
  }

  factory Kullanici.fromMap(Map<String, dynamic> map) {
    return Kullanici(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      adminMi: map['adminMi'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'adminMi': adminMi,
    };
  }
}
