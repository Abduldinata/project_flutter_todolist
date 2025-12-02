import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../utils/neumorphic_decoration.dart';

class SearchPopup extends StatefulWidget {
  const SearchPopup({super.key});

  @override
  State<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bg.withValues(alpha: 0.9),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: Neu.concave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Search", style: AppStyle.title),
            const SizedBox(height: 20),
            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                hintText: "Ketik untuk mencari...",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, searchCtrl.text);
              },
              child: const Text("Cari"),
            ),
          ],
        ),
      ),
    );
  }
}
