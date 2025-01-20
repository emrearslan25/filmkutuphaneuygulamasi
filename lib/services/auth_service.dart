import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kullanici.dart';
import 'package:filmizlemeuygulamasi/services/log_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı stream'i
  Stream<Kullanici?> get kullaniciDurumu {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return Kullanici.fromFirebaseUser(user);
    });
  }

  // Giriş yap
  Future<Kullanici?> girisYap(String email, String sifre) async {
    try {
      final sonuc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      if (sonuc.user != null) {
        final kullaniciDoc = await _firestore
            .collection('kullanicilar')
            .doc(sonuc.user!.uid)
            .get();

        final adminMi = kullaniciDoc.data()?['adminMi'] ?? false;
        return Kullanici.fromFirebaseUser(sonuc.user!, adminMi: adminMi);
      }
      return null;
    } catch (e) {
      LogService.error('Giriş yaparken hata oluştu', e);
      return null;
    }
  }

  // Kayıt ol
  Future<Kullanici?> kayitOl(String email, String sifre) async {
    try {
      final sonuc = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      if (sonuc.user != null) {
        // Yeni kullanıcı için Firestore'da döküman oluştur
        await _firestore.collection('kullanicilar').doc(sonuc.user!.uid).set({
          'email': email,
          'adminMi': false,
          'olusturulmaTarihi': FieldValue.serverTimestamp(),
        });

        return Kullanici.fromFirebaseUser(sonuc.user!);
      }
      return null;
    } catch (e) {
      LogService.error('Kayıt olurken hata oluştu', e);
      return null;
    }
  }

  // Çıkış yap
  Future<void> cikisYap() async {
    try {
      await _auth.signOut();
    } catch (e) {
      LogService.error('Çıkış yaparken hata oluştu', e);
      rethrow;
    }
  }

  Future<bool> adminMi(String uid) async {
    try {
      final doc = await _firestore.collection('kullanicilar').doc(uid).get();
      return doc.data()?['adminMi'] ?? false;
    } catch (e) {
      LogService.error('Admin kontrolü yapılırken hata oluştu', e);
      return false;
    }
  }
}
