import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/album_provider.dart';
import '../../core/assets.dart';
import '../../core/theme.dart';

const List<String> _kTwibbonAssets = [
  AppAssets.twibbon1,
  AppAssets.twibbon2,
  AppAssets.twibbon3,
];

const List<String> _kTwibbonLabels = [
  'Frame Alam 🌿',
  'Frame Produktif 🎯',
  'Frame Ceria ☀️',
];

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlbumProvider>().loadPhotos();
    });
  }

  // ── Tombol pilih sumber foto
  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tambah Foto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primaryDark),
                  ),
                  title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ambil foto baru'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickAndShowTwibbonSheet(fromCamera: true);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pilih dari galeri'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickAndShowTwibbonSheet(fromCamera: false);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Alur: Ambil foto → Geotag → Pilih Twibbon → Simpan ─────────────────────
  Future<void> _pickAndShowTwibbonSheet({required bool fromCamera}) async {
    final provider = context.read<AlbumProvider>();

    // 1. Tampilkan loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white),
              ),
              SizedBox(width: 12),
              Text('Mengambil foto & lokasi...'),
            ],
          ),
          duration: const Duration(seconds: 6),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }

    // 2. Ambil foto + geotag (di provider)
    final data = fromCamera
        ? await provider.pickFromCamera()
        : await provider.pickFromGallery();

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto')),
      );
      return;
    }

    // 3. Tampilkan bottom sheet pilihan twibbon
    _showTwibbonPicker(pickedPath: data.path, location: data.location);
  }

  // ── Bottom Sheet: Pilih Twibbon ──────────────────────────────────────────────
  void _showTwibbonPicker({required String pickedPath, String? location}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Frame (Opsional)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih frame twibbon atau simpan tanpa frame.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (location != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(location,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF388E3C))),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // Preview twibbon dalam baris horizontal
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _kTwibbonAssets.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveEntry(
                          path: pickedPath,
                          twibbonIndex: i,
                          location: location,
                        );
                      },
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Preview foto asli (kecil)
                                    Image.file(File(pickedPath), fit: BoxFit.cover),
                                    // Preview twibbon overlay
                                    Image.asset(
                                      _kTwibbonAssets[i],
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.backgroundGreenLight,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(12)),
                              ),
                              child: Text(
                                _kTwibbonLabels[i],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Simpan tanpa twibbon (index -1)
                      _saveEntry(
                          path: pickedPath, twibbonIndex: -1, location: location);
                    },
                    child: const Text('📷 Simpan Tanpa Frame'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveEntry({
    required String path,
    required int twibbonIndex,
    String? location,
  }) async {
    await context.read<AlbumProvider>().savePhotoWithTwibbon(
          path: path,
          twibbonIndex: twibbonIndex,
          location: location,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📸 Foto tersimpan di album!'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final album = context.watch<AlbumProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Album Memori'),
            Text(
              '${album.entries.length} foto tersimpan',
              style: const TextStyle(fontSize: 12, color: AppColors.white70),
            ),
          ],
        ),
      ),
      body: album.isLoading
          ? const Center(child: CircularProgressIndicator())
          : album.entries.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: album.entries.length,
                    itemBuilder: (ctx, i) => _PhotoTile(
                      entry: album.entries[i],
                      index: i,
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPickOptions,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Tambah Foto'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('📸', style: TextStyle(fontSize: 50))),
          ),
          const SizedBox(height: 20),
          const Text('Album masih kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol di bawah untuk\nmenambah foto pertamamu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          const Text('🌿', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            'Dokumentasikan momen wellbeing-mu!',
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ─── Photo Tile ───────────────────────────────────────────────────────────────
class _PhotoTile extends StatelessWidget {
  final PhotoEntry entry;
  final int index;
  const _PhotoTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _PhotoDetailScreen(entry: entry, index: index),
        ),
      ),
      onLongPress: () => _showDeleteDialog(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: Foto User ────────────────────────────────────────
            Image.file(
              File(entry.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              ),
            ),

            // ── Layer 2: Twibbon via Image.asset (bukan CustomPaint) ──────
            Image.asset(
              _kTwibbonAssets[entry.twibbonIndex.clamp(0, 2)],
              fit: BoxFit.cover,
            ),

            // ── Layer 3: Lokasi kecil di bawah frame ─────────────────────
            if (entry.location != null)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  color: AppColors.black.withOpacity(0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 8, color: AppColors.white70),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          entry.location!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Foto?'),
        content: const Text('Foto ini akan dihapus dari album dan perangkat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AlbumProvider>().deletePhoto(entry.path);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ─── Photo Detail Screen ──────────────────────────────────────────────────────
class _PhotoDetailScreen extends StatelessWidget {
  final PhotoEntry entry;
  final int index;
  const _PhotoDetailScreen({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foto #${index + 1}'),
            if (entry.location != null)
              Text(
                '📍 ${entry.location}',
                style: const TextStyle(fontSize: 11, color: AppColors.white60),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Foto?'),
                  content:
                      const Text('Foto ini akan dihapus permanen dari perangkat.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal')),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        context.read<AlbumProvider>().deletePhoto(entry.path);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Foto asli (zoomable)
            InteractiveViewer(
              child: Image.file(
                File(entry.path),
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: AppColors.white, size: 60),
              ),
            ),
            // Twibbon overlay penuh
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  _kTwibbonAssets[entry.twibbonIndex.clamp(0, 2)],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
