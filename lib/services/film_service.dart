import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/film.dart';
import 'package:filmizlemeuygulamasi/services/log_service.dart';

class FilmService {
  final CollectionReference _filmlerRef =
      FirebaseFirestore.instance.collection('filmler');

  // Film ekle
  Future<void> filmEkle(Film film) async {
    try {
      await _filmlerRef.add(film.toMap());
    } catch (e) {
      LogService.error('Film eklenirken hata oluştu', e);
      rethrow;
    }
  }

  // Tüm filmleri getir
  Stream<List<Film>> filmleriGetir() {
    return _filmlerRef
        .orderBy('eklenmeZamani', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Film.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Film güncelle
  Future<void> filmGuncelle(String filmId, Film film) async {
    try {
      await _filmlerRef.doc(filmId).update(film.toMap());
    } catch (e) {
      LogService.error('Film güncellenirken hata oluştu', e);
      rethrow;
    }
  }

  // Film sil
  Future<void> filmSil(String filmId) async {
    try {
      await _filmlerRef.doc(filmId).delete();
    } catch (e) {
      LogService.error('Film silinirken hata oluştu', e);
      rethrow;
    }
  }

  // Film ara
  Future<List<Film>> filmAra(String aramaMetni) async {
    try {
      final querySnapshot = await _filmlerRef
          .where('baslik', isGreaterThanOrEqualTo: aramaMetni)
          .where('baslik', isLessThanOrEqualTo: '$aramaMetni\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        return Film.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      LogService.error('Film aranırken hata oluştu', e);
      rethrow;
    }
  }

  Future<List<Film>> kullaniciFilmleriniGetir(String kullaniciId) async {
    try {
      final querySnapshot = await _filmlerRef
          .where('ekleyenId', isEqualTo: kullaniciId)
          .orderBy('eklenmeZamani', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Film.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      LogService.error('Kullanıcı filmleri getirilirken hata oluştu', e);
      rethrow;
    }
  }
}
