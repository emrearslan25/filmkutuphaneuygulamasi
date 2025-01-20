import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';

class FilmEklemeEkrani extends StatefulWidget {
  const FilmEklemeEkrani({super.key});

  @override
  State<FilmEklemeEkrani> createState() => _FilmEklemeEkraniState();
}

class _FilmEklemeEkraniState extends State<FilmEklemeEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _filmAdiController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _afisUrlController = TextEditingController();
  final _filmPuaniController = TextEditingController();

  void _filmEkle() async {
    if (_formKey.currentState!.validate()) {
      try {
        final puan = double.parse(_filmPuaniController.text);
        if (puan > 5.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Film puanı 5\'ten büyük olamaz!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('filmler').add({
          'filmAdi': _filmAdiController.text.trim(),
          'aciklama': _aciklamaController.text.trim(),
          'afisUrl': _afisUrlController.text.trim(),
          'filmPuani': puan,
          'eklemeTarihi': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Film başarıyla eklendi'),
              backgroundColor: Colors.green,
            ),
          );
          _formKey.currentState!.reset();
          _filmAdiController.clear();
          _aciklamaController.clear();
          _afisUrlController.clear();
          _filmPuaniController.clear();
        }
      } catch (e) {
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
        title: const Text('Film Ekle'),
        backgroundColor: AppColors.appBar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _filmAdiController,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  labelText: 'Film Adı',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Film adı gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aciklamaController,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  labelText: 'Film Açıklaması',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Film açıklaması gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _afisUrlController,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  labelText: 'Film Afiş URL',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Film afiş URL gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _filmPuaniController,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  labelText: 'Film Puanı (1-5)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Film puanı gerekli';
                  final puan = double.tryParse(value!);
                  if (puan == null || puan < 0 || puan > 5) {
                    return 'Film puanı 0-5 arasında olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C), // Koyu kırmızı
                  ),
                  onPressed: _filmEkle,
                  child: const Text(
                    'Film Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _filmAdiController.dispose();
    _aciklamaController.dispose();
    _afisUrlController.dispose();
    _filmPuaniController.dispose();
    super.dispose();
  }
}
