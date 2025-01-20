import 'package:cloud_firestore/cloud_firestore.dart';

class Film {
  final String? id;
  final String baslik;
  final String aciklama;
  final String? posterUrl;
  final String yonetmen;
  final List<String> oyuncular;
  final int yil;
  final double ortalamaPuan;
  final int oySayisi;
  final String ekleyenId;
  final DateTime eklenmeZamani;

  Film({
    this.id,
    required this.baslik,
    required this.aciklama,
    this.posterUrl,
    required this.yonetmen,
    required this.oyuncular,
    required this.yil,
    this.ortalamaPuan = 0.0,
    this.oySayisi = 0,
    required this.ekleyenId,
    DateTime? eklenmeZamani,
  }) : eklenmeZamani = eklenmeZamani ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'posterUrl': posterUrl,
      'yonetmen': yonetmen,
      'oyuncular': oyuncular,
      'yil': yil,
      'ortalamaPuan': ortalamaPuan,
      'oySayisi': oySayisi,
      'ekleyenId': ekleyenId,
      'eklenmeZamani': eklenmeZamani,
    };
  }

  factory Film.fromMap(String id, Map<String, dynamic> map) {
    return Film(
      id: id,
      baslik: map['baslik'] ?? '',
      aciklama: map['aciklama'] ?? '',
      posterUrl: map['posterUrl'],
      yonetmen: map['yonetmen'] ?? '',
      oyuncular: List<String>.from(map['oyuncular'] ?? []),
      yil: map['yil']?.toInt() ?? 0,
      ortalamaPuan: (map['ortalamaPuan'] ?? 0.0).toDouble(),
      oySayisi: map['oySayisi']?.toInt() ?? 0,
      ekleyenId: map['ekleyenId'] ?? '',
      eklenmeZamani: (map['eklenmeZamani'] as Timestamp).toDate(),
    );
  }
}
