import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme.dart';
import '../../models/plant_model.dart';
import '../../services/database_helper.dart';
import '../../services/ml_service.dart';
import '../../services/plant_database_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isAnalyzing = false;
  String? _resultLabel;
  String? _resultLatin;
  double? _confidence;
  bool _isSuccess = false;
  PlantModel _selectedModel = PlantModel.aiy;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Pre-load model & plant database
    MLService().initModel();
    PlantDatabaseService().init();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _resultLabel = null;
        _resultLatin = null;
        _isSuccess = false;
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
      _resultLabel = null;
      _resultLatin = null;
      _confidence = null;
      _isSuccess = false;
    });

    try {
      final result = await MLService().predictPlant(_image!);

      if (result != null) {
        String plantName = result['label'].toString();
        plantName = plantName
            .split(' ')
            .map((w) => w.isEmpty
                ? ''
                : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join(' ');
        final String latinName = result['latinName'] as String? ?? '';
        final String benefits  = result['benefits']  as String? ?? '';
        final double conf = (result['confidence'] as double) * 100;

        // Simpan gambar ke storage lokal
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'plant_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await _image!.copy(p.join(appDir.path, fileName));

        // Waktu dengan akurasi jam + menit
        final String discoveredAt =
            DateFormat('dd MMM yyyy \u2022 HH:mm').format(DateTime.now());

        // Ambil kota dari GPS
        String city = 'Lokasi tidak diketahui';
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (serviceEnabled &&
              (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always)) {
            Position pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium);
            List<Placemark> marks =
                await placemarkFromCoordinates(pos.latitude, pos.longitude);
            if (marks.isNotEmpty) {
              final place = marks.first;
              city = place.locality?.isNotEmpty == true
                  ? place.locality!
                  : (place.subAdministrativeArea ?? 'Kota tidak diketahui');
            }
          }
        } catch (e) {
          debugPrint('Gagal ambil lokasi: $e');
        }

        final newPlant = DiscoveredPlant(
          name: plantName,
          latinName: latinName,
          benefits: benefits,
          confidence: conf,
          city: city,
          discoveredAt: discoveredAt,
          imagePath: savedImage.path,
        );
        await DatabaseHelper.instance.insertDiscoveredPlant(newPlant);

        setState(() {
          _isSuccess = true;
          _resultLabel = plantName;
          _resultLatin = latinName.isNotEmpty ? latinName : null;
          _confidence = conf;
        });
      } else {
        setState(() {
          _isSuccess = false;
          _resultLabel = 'Tanaman tidak teridentifikasi.\nCoba foto lebih dekat atau ganti sudut.';
          _resultLatin = null;
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _resultLabel = 'Terjadi kesalahan:\n$e';
        _resultLatin = null;
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'AI Plant Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreenLight, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Model Selector Dropdown ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PlantModel>(
                      value: _selectedModel,
                      isDense: true,
                      icon: const Icon(Icons.expand_more,
                          color: AppColors.primaryDark, size: 20),
                      onChanged: _isAnalyzing
                          ? null
                          : (val) async {
                              if (val == null) return;
                              setState(() {
                                _selectedModel = val;
                                _resultLabel = null;
                                _resultLatin = null;
                              });
                              await MLService().setModel(val);
                              if (_image != null) _analyzeImage();
                            },
                      items: PlantModel.values
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome,
                                        size: 14, color: AppColors.primaryDark),
                                    const SizedBox(width: 8),
                                    Text(
                                      m.displayName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Foto Preview ─────────────────────────────────────────
                _buildImagePreview(),
                const SizedBox(height: 28),

                // ── Hasil / Loading ───────────────────────────────────────
                _buildResultArea(),
                const SizedBox(height: 32),

                // ── Tombol Action ─────────────────────────────────────────
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return AnimatedBuilder(
      animation: _isAnalyzing ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      builder: (ctx, child) => Transform.scale(
        scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
        child: child,
      ),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: _isAnalyzing
                ? AppColors.primary
                : AppColors.backgroundGreenLight,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: _image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_image!, fit: BoxFit.cover),
                    if (_isAnalyzing)
                      Container(
                        color: AppColors.black.withOpacity(0.35),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                  color: AppColors.white, strokeWidth: 3),
                              SizedBox(height: 12),
                              Text(
                                'Menganalisis...',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 72,
                        color: AppColors.primary.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Ambil atau pilih foto tanaman',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Model akan mengidentifikasi spesies tanaman',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_isAnalyzing) return const SizedBox.shrink();

    if (_resultLabel == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundGreenLight,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Foto tanaman lalu AI akan langsung mengidentifikasi spesiesnya.',
                style: TextStyle(
                    color: AppColors.primaryDark, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isSuccess
            ? AppColors.backgroundGreenLight
            : AppColors.backgroundLightRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSuccess ? AppColors.primary : Colors.red.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isSuccess ? AppColors.primary : Colors.red)
                .withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isSuccess
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isSuccess
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: _isSuccess ? AppColors.primaryDark : Colors.red.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSuccess ? '✅ Teridentifikasi!' : '❌ Gagal Dikenali',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _isSuccess
                        ? AppColors.primaryDarker
                        : Colors.red.shade800,
                  ),
                ),
                if (_isSuccess && _confidence != null) ...[
                  Text(
                    'AI Confidence: ${_confidence!.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryDark.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _resultLabel!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _isSuccess
                        ? AppColors.primaryDark
                        : Colors.red.shade700,
                    height: 1.4,
                  ),
                ),
                if (_isSuccess && _resultLatin != null) ...[   
                  const SizedBox(height: 4),
                  Text(
                    _resultLatin!,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt, size: 22),
            label: const Text('Kamera',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library, size: 22),
            label: const Text('Galeri',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
