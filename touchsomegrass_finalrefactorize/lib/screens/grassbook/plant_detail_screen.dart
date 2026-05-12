import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/plant_model.dart';
import '../../services/database_helper.dart';

class PlantDetailScreen extends StatelessWidget {
  final DiscoveredPlant plant;
  final VoidCallback? onDelete;

  const PlantDetailScreen({
    super.key,
    required this.plant,
    this.onDelete,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Koleksi?'),
        content: const Text('Data tanaman ini akan dihapus permanen dari album kamu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (plant.id != null) {
                await DatabaseHelper.instance.deleteDiscoveredPlant(plant.id!);
                if (plant.imagePath != null) {
                  final file = File(plant.imagePath!);
                  if (await file.exists()) await file.delete();
                }
                onDelete?.call();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // ── Premium Sliver Header ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryDark,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () => _confirmDelete(context),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Hero(
                tag: 'plant_image_${plant.id}',
                child: plant.imagePath != null
                    ? Image.file(File(plant.imagePath!), fit: BoxFit.cover)
                    : Container(
                        color: AppColors.backgroundGreenLight,
                        child: const Center(child: Text('🌿', style: TextStyle(fontSize: 80))),
                      ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Confidence
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: AppColors.primaryDark, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'AI Confidence: ${plant.confidence.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDarker,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    // Latin Name
                    if (plant.latinName.isNotEmpty && plant.latinName != 'Spesies tidak dikenal') ...[
                      const SizedBox(height: 4),
                      Text(
                        plant.latinName,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Discovery Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGreenLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _buildDiscoveryItem(
                            icon: Icons.location_city_rounded,
                            label: 'Lokasi Penemuan',
                            value: plant.city,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          _buildDiscoveryItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'Waktu Penemuan',
                            value: plant.discoveredAt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Benefits Section
                    const Text(
                      'Manfaat & Informasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarker,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plant.benefits,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Fun Fact Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.tips_and_updates, color: Colors.white, size: 28),
                          SizedBox(height: 12),
                          Text(
                            'Tahukah Kamu?',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Menyentuh tanah atau tanaman (Earthing) dapat menurunkan tingkat stres dan meningkatkan imunitas tubuh kita. Yuk, terus jelajahi alam!',
                            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryItem({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDarker)),
            ],
          ),
        ),
      ],
    );
  }
}
