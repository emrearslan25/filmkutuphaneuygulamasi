import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/film_puanlama_dialog.dart';

class FilmListesiEkrani extends StatelessWidget {
  const FilmListesiEkrani({super.key});

  Future<int?> _kullaniciPuaniniGetir(String filmId, String kullaniciId) async {
    if (kullaniciId.isEmpty) return null;

    final puanlama = await FirebaseFirestore.instance
        .collection('kullanici_puanlamalari')
        .where('filmId', isEqualTo: filmId)
        .where('kullaniciId', isEqualTo: kullaniciId)
        .get();

    if (puanlama.docs.isNotEmpty) {
      return puanlama.docs.first.data()['puan'] as int;
    }
    return null;
  }

  void _filmPuanla(BuildContext context, String filmId, String filmAdi) async {
    final kullaniciId = FirebaseAuth.instance.currentUser?.uid;
    if (kullaniciId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Puanlama yapmak için giriş yapmalısınız'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kullanıcının mevcut puanını kontrol et
    final mevcutPuan = await _kullaniciPuaniniGetir(filmId, kullaniciId);

    if (mevcutPuan != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Bu filmi zaten puanladınız. Puanınızı "Puanladığım Filmler" sayfasından düzenleyebilirsiniz.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      showDialog(
        context: context,
        builder: (context) => FilmPuanlamaDialog(
          puanlamaYapildi: (puan) async {
            try {
              await FirebaseFirestore.instance
                  .collection('kullanici_puanlamalari')
                  .add({
                'kullaniciId': kullaniciId,
                'filmId': filmId,
                'filmAdi': filmAdi,
                'puan': puan,
                'puanlamaTarihi': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Film başarıyla puanlandı'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filmler'),
        backgroundColor: AppColors.appBar,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('filmler').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final film =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final filmId = snapshot.data!.docs[index].id;

                return FutureBuilder<int?>(
                  future: _kullaniciPuaniniGetir(
                      filmId, FirebaseAuth.instance.currentUser?.uid ?? ''),
                  builder: (context, puanSnapshot) {
                    return GestureDetector(
                      onTap: () =>
                          _filmPuanla(context, filmId, film['filmAdi']),
                      child: Card(
                        color: AppColors.cardBackground,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: Image.network(
                                  film['afisUrl'] ??
                                      'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.cardBackground,
                                      child: const Icon(
                                        Icons.movie,
                                        size: 50,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      film['filmAdi'] ?? 'İsimsiz Film',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      film['aciklama'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Film puanı
                                        if (film['filmPuani'] != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${film['filmPuani']}',
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        // Kullanıcı puanı
                                        FutureBuilder<int?>(
                                          future: _kullaniciPuaniniGetir(
                                              filmId,
                                              FirebaseAuth.instance.currentUser
                                                      ?.uid ??
                                                  ''),
                                          builder: (context, puanSnapshot) {
                                            final user = FirebaseAuth
                                                .instance.currentUser;
                                            if (user == null) {
                                              return const Text(
                                                'Giriş Yapılmadı',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              );
                                            }

                                            if (puanSnapshot.hasData &&
                                                puanSnapshot.data != null) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${puanSnapshot.data}',
                                                    style: const TextStyle(
                                                      color: AppColors.text,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
