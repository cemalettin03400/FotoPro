import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const FotoProApp());

class FotoProApp extends StatelessWidget {
  const FotoProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FotoPro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F80ED),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();
  File? _image;
  double _brightness = 0;
  double _contrast = 1;
  double _saturation = 1;
  double _warmth = 0;
  String _filter = 'Orijinal';
  String _frame = 'Yok';
  String _text = '';

  final filters = const ['Orijinal', 'Canlı', 'Berrak', 'Sıcak', 'Soğuk', 'Siyah-Beyaz'];
  final frames = const ['Yok', 'İnce', 'Kalın', 'Yuvarlak'];

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 100);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _resetAdjustments();
      });
    }
  }

  void _resetAdjustments() {
    _brightness = 0;
    _contrast = 1;
    _saturation = 1;
    _warmth = 0;
    _filter = 'Orijinal';
    _frame = 'Yok';
    _text = '';
  }

  Future<void> _crop() async {
    if (_image == null) return;
    final result = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'FotoPro - Kırp',
          toolbarColor: const Color(0xFF07111F),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'FotoPro - Kırp'),
      ],
    );
    if (result != null) setState(() => _image = File(result.path));
  }

  Future<void> _share() async {
    if (_image == null) return;
    await Share.shareXFiles(
      [XFile(_image!.path)],
      text: 'FotoPro ile düzenlendi 📸',
    );
  }

  Future<void> _addText() async {
    final controller = TextEditingController(text: _text);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fotoğrafa Yazı Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Yazınızı girin',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Ekle')),
        ],
      ),
    );
    if (value != null) setState(() => _text = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: 'Foto', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Pro', style: TextStyle(color: Color(0xFFFFC107))),
            ],
          ),
        ),
        actions: [
          if (_image != null)
            IconButton(
              tooltip: 'Paylaş',
              onPressed: _share,
              icon: const Icon(Icons.share),
            ),
        ],
      ),
      body: _image == null ? _home() : _editor(),
    );
  }

  Widget _home() => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.camera_alt_rounded, size: 90, color: Color(0xFFFFC107)),
              const SizedBox(height: 18),
              const Text(
                'Fotoğraflarınıza\nYeni Bir Dokunuş',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _homeButton(Icons.photo_library_rounded, 'Fotoğraf Seç', () => _pick(ImageSource.gallery)),
              const SizedBox(height: 14),
              _homeButton(Icons.camera_alt_rounded, 'Kamera ile Çek', () => _pick(ImageSource.camera)),
              const SizedBox(height: 28),
              const Text(
                'Ücretsiz • Filigran Yok • Android + iOS',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      );

  Widget _homeButton(IconData icon, String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        height: 62,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 28),
          label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _editor() => Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: _frameBorder(),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: _colorFilter(),
                    child: Image.file(_image!, fit: BoxFit.contain),
                  ),
                  if (_text.trim().isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black),
                              Shadow(blurRadius: 3, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 132,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _tool(Icons.crop, 'Kırp', _crop),
                _tool(Icons.tune, 'Ayarla', _showAdjustments),
                _tool(Icons.auto_awesome, 'Filtre', _showFilters),
                _tool(Icons.text_fields, 'Yazı', _addText),
                _tool(Icons.crop_square, 'Çerçeve', _showFrames),
                _tool(Icons.restart_alt, 'Sıfırla', () => setState(_resetAdjustments)),
                _tool(Icons.share, 'Paylaş', _share),
              ],
            ),
          ),
        ],
      );

  ColorFilter _colorFilter() {
    double r = _contrast * _saturation;
    double g = _contrast;
    double b = _contrast * _saturation;
    if (_filter == 'Canlı') {
      r *= 1.12; g *= 1.08; b *= 1.16;
    } else if (_filter == 'Berrak') {
      r *= 1.04; g *= 1.04; b *= 1.04;
    } else if (_filter == 'Sıcak') {
      r *= 1.12; b *= 0.90;
    } else if (_filter == 'Soğuk') {
      r *= 0.90; b *= 1.12;
    } else if (_filter == 'Siyah-Beyaz') {
      r = g = b = 0.299;
    }
    final warmthR = _warmth * 40;
    final warmthB = -_warmth * 40;
    final br = _brightness * 255;
    return ColorFilter.matrix([
      r, 0, 0, 0, br + warmthR,
      0, g, 0, 0, br,
      0, 0, b, 0, br + warmthB,
      0, 0, 0, 1, 0,
    ]);
  }

  Border? _frameBorder() {
    if (_frame == 'İnce') return Border.all(color: Colors.white, width: 3);
    if (_frame == 'Kalın') return Border.all(color: Colors.white, width: 9);
    if (_frame == 'Yuvarlak') return Border.all(color: const Color(0xFFFFC107), width: 6);
    return null;
  }

  Widget _tool(IconData icon, String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 14),
        child: FilledButton.tonalIcon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
        ),
      );

  Future<void> _showAdjustments() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ayarlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                _sheetSlider('Parlaklık', _brightness, -1, 1, (v) {
                  setState(() => _brightness = v); setSheetState(() {});
                }),
                _sheetSlider('Kontrast', _contrast, 0.5, 1.8, (v) {
                  setState(() => _contrast = v); setSheetState(() {});
                }),
                _sheetSlider('Doygunluk', _saturation, 0, 2, (v) {
                  setState(() => _saturation = v); setSheetState(() {});
                }),
                _sheetSlider('Sıcaklık', _warmth, -1, 1, (v) {
                  setState(() => _warmth = v); setSheetState(() {});
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetSlider(String title, double value, double min, double max, ValueChanged<double> onChanged) => Row(
        children: [
          SizedBox(width: 85, child: Text(title)),
          Expanded(child: Slider(value: value, min: min, max: max, onChanged: onChanged)),
        ],
      );

  Future<void> _showFilters() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: filters.map((f) => ChoiceChip(
              label: Text(f),
              selected: _filter == f,
              onSelected: (_) {
                setState(() => _filter = f);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _showFrames() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Wrap(
            spacing: 10,
            children: frames.map((f) => ChoiceChip(
              label: Text(f),
              selected: _frame == f,
              onSelected: (_) {
                setState(() => _frame = f);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }
}
