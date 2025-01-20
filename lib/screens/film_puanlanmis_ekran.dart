import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/film_puanlama_dialog.dart';

class FilmPuanlanmisEkran extends StatelessWidget {
  const FilmPuanlanmisEkran({super.key});

  void _puanGuncelle(
      BuildContext context, String puanlamaId, String filmAdi, int mevcutPuan) {
    showDialog(
      context: context,
      builder: (context) => FilmPuanlamaDialog(
        puanlamaYapildi: (yeniPuan) async {
          try {
            await FirebaseFirestore.instance
                .collection('kullanici_puanlamalari')
                .doc(puanlamaId)
                .update({'puan': yeniPuan});

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Film puanı güncellendi'),
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
        baslangicPuani: mevcutPuan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;

    if (kullaniciId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Puanladığım Filmler'),
          backgroundColor: AppColors.appBar,
        ),
        body: const Center(
          child: Text(
            'Lütfen önce giriş yapın',
            style: TextStyle(color: AppColors.text),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Puanladığım Filmler'),
        backgroundColor: AppColors.appBar,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kullanici_puanlamalari')
            .where('kullaniciId', isEqualTo: kullaniciId)
            .orderBy('puanlamaTarihi', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu: ${snapshot.error}',
                style: const TextStyle(color: AppColors.text),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz film puanlamadınız',
                style: TextStyle(color: AppColors.text),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final puanlama = docs[index].data() as Map<String, dynamic>;
              final puanlamaId = docs[index].id;

              return Card(
                color: AppColors.cardBackground,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    puanlama['filmAdi'] ?? 'İsimsiz Film',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                        5,
                        (starIndex) => Icon(
                          Icons.star,
                          color: starIndex < (puanlama['puan'] ?? 0)
                              ? Colors.amber
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _puanGuncelle(
                          context,
                          puanlamaId,
                          puanlama['filmAdi'],
                          puanlama['puan'],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _puanGuncelle(
                    context,
                    puanlamaId,
                    puanlama['filmAdi'],
                    puanlama['puan'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
