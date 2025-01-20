import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/kullanici.dart';
import '../styles/app_colors.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _kayitModu = false;

  Future<void> _girisYapVeyaKayitOl(bool kayitModu) async {
    if (_formKey.currentState!.validate()) {
      try {
        Kullanici? kullanici;
        if (kayitModu) {
          kullanici = await _authService.kayitOl(
            _emailController.text,
            _sifreController.text,
          );
        } else {
          kullanici = await _authService.girisYap(
            _emailController.text,
            _sifreController.text,
          );
        }

        if (!mounted) return;

        if (kullanici != null) {
          if (kullanici.adminMi) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/kullanici');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giriş başarısız')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_kayitModu ? 'Kayıt Ol' : 'Giriş Yap'),
        backgroundColor: AppColors.appBar,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sifreController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
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
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => _girisYapVeyaKayitOl(_kayitModu),
                  child: Text(_kayitModu ? 'Kayıt Ol' : 'Giriş Yap'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _kayitModu = !_kayitModu;
                  });
                },
                child: Text(_kayitModu
                    ? 'Zaten hesabınız var mı? Giriş yapın'
                    : 'Hesabınız yok mu? Kayıt olun'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }
}
