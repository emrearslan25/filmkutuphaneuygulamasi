import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FilmPuanlamaDialog extends StatefulWidget {
  final Function(int) puanlamaYapildi;
  final int? baslangicPuani;

  const FilmPuanlamaDialog({
    super.key,
    required this.puanlamaYapildi,
    this.baslangicPuani,
  });

  @override
  State<FilmPuanlamaDialog> createState() => _FilmPuanlamaDialogState();
}

class _FilmPuanlamaDialogState extends State<FilmPuanlamaDialog> {
  late int _secilenPuan;

  @override
  void initState() {
    super.initState();
    _secilenPuan = widget.baslangicPuani ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        widget.baslangicPuani != null ? 'Puanı Güncelle' : 'Film Puanla',
        style: const TextStyle(color: AppColors.text),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          5,
          (index) => IconButton(
            icon: Icon(
              Icons.star,
              color: index < _secilenPuan ? Colors.amber : Colors.grey,
              size: 32,
            ),
            onPressed: () {
              setState(() {
                _secilenPuan = index + 1;
              });
              widget.puanlamaYapildi(_secilenPuan);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
