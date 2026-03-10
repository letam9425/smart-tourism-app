// lib/screens/translate_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_tourism_app/services/api_service.dart';

class TranslateScreen extends StatefulWidget {
  final String originalText;

  const TranslateScreen({super.key, required this.originalText});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String _translated = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _translate();
  }

  Future<void> _translate() async {
    setState(() => _isLoading = true);
    try {
      final translated = await ApiService().translateText(
        text: widget.originalText,
        targetLang: 'en',
      );
      setState(() => _translated = translated);
    } catch (e) {
      setState(() => _translated = 'Lỗi dịch: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dịch nội dung')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nguyên bản:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.originalText),
            const SizedBox(height: 24),
            const Text('Dịch sang tiếng Anh:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(_translated.isEmpty ? 'Đang dịch...' : _translated),
          ],
        ),
      ),
    );
  }
}