import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/database_helper.dart';
import '../../models/plant_model.dart';
import 'scanner_screen.dart';
import 'plant_detail_screen.dart';

class GrassbookScreen extends StatefulWidget {
  const GrassbookScreen({super.key});

  @override
  State<GrassbookScreen> createState() => _GrassbookScreenState();
}

class _GrassbookScreenState extends State<GrassbookScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  List<DiscoveredPlant> _unlockedPlants = [];
  List<DiscoveredPlant> _filteredPlants = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final plants = await DatabaseHelper.instance.getDiscoveredPlants();
    setState(() {
      _unlockedPlants = plants;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredPlants = List.from(_unlockedPlants);
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredPlants = _unlockedPlants.where((p) {
          return p.name.toLowerCase().contains(query) ||
                 p.latinName.toLowerCase().contains(query) ||
                 p.city.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmDelete(DiscoveredPlant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tanaman?'),
        content: const Text('Apakah kamu yakin ingin menghapus data tanaman ini dari album?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (plant.id != null) {
                await DatabaseHelper.instance.deleteDiscoveredPlant(plant.id!);
                if (plant.imagePath != null) {
                  final file = File(plant.imagePath!);
                  if (await file.exists()) {
                    await file.delete();
                  }
                }
                _loadPlants();
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
      appBar: AppBar(
        title: const Text('Grassbook', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreenLight, AppColors.backgroundLight, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
            child: Column(
              children: [
                // Floating plant illustration
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  ),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: const Center(child: Text('🌿', style: TextStyle(fontSize: 72))),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Grassbook - Pelajari Tanaman di Sekitarmu',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDarker, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Scan tanaman, jelajahi alam, dan dapatkan insight tentang beragam spesies di sekitarmu.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Feature preview cards
                const _FeatureCard(
                  icon: Icons.camera_alt,
                  iconBg: AppColors.backgroundGreenLight,
                  iconColor: AppColors.primaryDark,
                  title: 'Scan Tanaman',
                  desc: 'Arahkan kamera ke tanaman untuk mengenali jenis dan karakteristiknya.',
                ),
                const SizedBox(height: 12),
                const _FeatureCard(
                  icon: Icons.search,
                  iconBg: AppColors.backgroundGreenLight,
                  iconColor: AppColors.primaryDark,
                  title: 'Insight Spesies',
                  desc: 'Lihat informasi singkat, manfaat, dan fakta menarik dari tanaman yang kamu temui.',
                ),
                const SizedBox(height: 12),
                const _FeatureCard(
                  icon: Icons.book,
                  iconBg: AppColors.backgroundGreenLight,
                  iconColor: AppColors.primaryDark,
                  title: 'Plant Entry',
                  desc: 'Kumpulkan data tanaman yang sudah pernah kamu scan dan bangun koleksi pribadimu.',
                ),
                const SizedBox(height: 12),
                const _FeatureCard(
                  icon: Icons.map_outlined,
                  iconBg: AppColors.backgroundGreenLight,
                  iconColor: AppColors.primaryDark,
                  title: 'Jelajahi Alam',
                  desc: 'Temukan tanaman unik di sekitarmu dan catat lokasi penemuanmu.',
                ),
                const SizedBox(height: 32),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari koleksi tanaman...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyFilter();
                              });
                            },
                          )
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Scanner
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.document_scanner),
                    label: const Text('Buka AI Scanner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                      _loadPlants();
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Koleksi Header
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Koleksi Tanaman Kamu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDarker),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_unlockedPlants.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada tanaman yang di-scan. Buka scanner dan mulai petualanganmu! 🌱',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = _filteredPlants[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailScreen(
                                plant: plant,
                                onDelete: () => _loadPlants(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Foto Tanaman
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Hero(
                                      tag: 'plant_image_${plant.id}',
                                      child: plant.imagePath != null
                                          ? Image.file(
                                              File(plant.imagePath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: AppColors.backgroundGreenLight,
                                              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 48))),
                                            ),
                                    ),
                                    // Tombol Hapus
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _confirmDelete(plant),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Info Text
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        plant.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDarker),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_city, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              plant.city.isNotEmpty ? plant.city : 'Lokasi tidak diketahui',
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              plant.discoveredAt,
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${plant.confidence.toStringAsFixed(0)}% Match',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
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
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, desc;

  const _FeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 3),
          Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
        ])),
      ]),
    );
  }
}
