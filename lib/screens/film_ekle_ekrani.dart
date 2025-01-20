import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/film.dart';
import '../models/kullanici.dart';
import '../services/film_service.dart';

class FilmEkleEkrani extends StatefulWidget {
  const FilmEkleEkrani({super.key});

  @override
  State<FilmEkleEkrani> createState() => _FilmEkleEkraniState();
}

class _FilmEkleEkraniState extends State<FilmEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _yonetmenController = TextEditingController();
  final _yilController = TextEditingController();
  final List<String> _oyuncular = [];
  final _oyuncuController = TextEditingController();
  final FilmService _filmService = FilmService();
  String? _posterUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _baslikController,
              decoration: const InputDecoration(labelText: 'Film Başlığı'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen film başlığını girin';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _aciklamaController,
              decoration: const InputDecoration(labelText: 'Film Açıklaması'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen film açıklamasını girin';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _yonetmenController,
              decoration: const InputDecoration(labelText: 'Yönetmen'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen yönetmen adını girin';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _yilController,
              decoration: const InputDecoration(labelText: 'Yapım Yılı'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen yapım yılını girin';
                }
                if (int.tryParse(value) == null) {
                  return 'Geçerli bir yıl girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _oyuncuController,
                    decoration: const InputDecoration(labelText: 'Oyuncu Ekle'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _oyuncuEkle,
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              children: _oyuncular
                  .map((oyuncu) => Chip(
                        label: Text(oyuncu),
                        onDeleted: () => _oyuncuSil(oyuncu),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _posterUrlGir,
              child: const Text('Poster URL\'si Ekle'),
            ),
            if (_posterUrl != null) ...[
              const SizedBox(height: 8),
              Image.network(
                _posterUrl!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _filmEkle,
              child: const Text('Film Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _oyuncuEkle() {
    final oyuncu = _oyuncuController.text.trim();
    if (oyuncu.isNotEmpty) {
      setState(() {
        _oyuncular.add(oyuncu);
        _oyuncuController.clear();
      });
    }
  }

  void _oyuncuSil(String oyuncu) {
    setState(() {
      _oyuncular.remove(oyuncu);
    });
  }

  Future<void> _posterUrlGir() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poster URL\'si'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/poster.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() {
        _posterUrl = url;
      });
    }
    controller.dispose();
  }

  Future<void> _filmEkle() async {
    if (_formKey.currentState!.validate()) {
      try {
        final film = Film(
          baslik: _baslikController.text,
          aciklama: _aciklamaController.text,
          posterUrl: _posterUrl,
          yonetmen: _yonetmenController.text,
          oyuncular: _oyuncular,
          yil: int.parse(_yilController.text),
          ekleyenId: Provider.of<Kullanici?>(context, listen: false)?.uid ?? '',
        );

        await _filmService.filmEkle(film);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Film eklenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _yonetmenController.dispose();
    _yilController.dispose();
    _oyuncuController.dispose();
    super.dispose();
  }
}
