import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import 'film_listesi_ekrani.dart';
import 'film_puanlanmis_ekran.dart';

class KullaniciPaneli extends StatefulWidget {
  const KullaniciPaneli({super.key});

  @override
  State<KullaniciPaneli> createState() => _KullaniciPaneliState();
}

class _KullaniciPaneliState extends State<KullaniciPaneli> {
  bool get girisYapilmis => FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kullanıcı Paneli'),
        backgroundColor: AppColors.appBar,
        actions: [
          IconButton(
            icon: Icon(girisYapilmis ? Icons.logout : Icons.login),
            onPressed: () async {
              if (girisYapilmis) {
                await FirebaseAuth.instance.signOut();
                setState(() {}); // UI'ı yenile
              } else {
                Navigator.pushNamed(context, '/giris');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200, // Sabit genişlik
              height: 50, // Sabit yükseklik
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FilmListesiEkrani(),
                    ),
                  );
                },
                child: const Text(
                  'Filmleri Görüntüle',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
            if (girisYapilmis) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 200, // Aynı genişlik
                height: 50, // Aynı yükseklik
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FilmPuanlanmisEkran(),
                      ),
                    );
                  },
                  child: const Text(
                    'Puanladığım Filmler',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.background,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
