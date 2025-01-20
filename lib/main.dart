import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/giris_ekrani.dart';
import 'screens/admin_paneli.dart';
import 'screens/kullanici_paneli.dart';
import 'screens/film_listesi_ekrani.dart';
import 'screens/film_puanlanmis_ekran.dart';
import 'utils/app_colors.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseConfig.platformOptions,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film İzleme Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBar,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.text),
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.text),
          titleLarge: TextStyle(color: AppColors.text),
          titleMedium: TextStyle(color: AppColors.text),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.textSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.textSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: const KullaniciPaneli(),
      routes: {
        '/giris': (context) => const GirisEkrani(),
        '/admin': (context) => const AdminPaneli(),
        '/kullanici': (context) => const KullaniciPaneli(),
        '/filmListesi': (context) => const FilmListesiEkrani(),
        '/puanlanmisFilmler': (context) => const FilmPuanlanmisEkran(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const KullaniciPaneli(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film İzleme Uygulaması'),
        backgroundColor: Colors.red.shade900,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10, // Örnek film sayısı
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        size: 50,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Film ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Film açıklaması burada yer alacak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Film ekleme işlemi
        },
        backgroundColor: Colors.red.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }
}
