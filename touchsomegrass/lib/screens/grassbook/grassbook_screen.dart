import 'package:flutter/material.dart';

class GrassbookScreen extends StatefulWidget {
  const GrassbookScreen({super.key});

  @override
  State<GrassbookScreen> createState() => _GrassbookScreenState();
}

class _GrassbookScreenState extends State<GrassbookScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grassbook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: const Center(child: Text('🌿', style: TextStyle(fontSize: 72))),
                  ),
                ),
                const SizedBox(height: 28),

                // Coming Soon badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF388E3C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('✨ COMING SOON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Grassbook - Pelajari Tanaman di Sekitarmu',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), height: 1.2),
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
                _FeatureCard(
                  icon: Icons.camera_alt,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  title: 'Scan Tanaman',
                  desc: 'Arahkan kamera ke tanaman untuk mengenali jenis dan karakteristiknya.',
                  isLocked: true,
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.search,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  title: 'Insight Spesies',
                  desc: 'Lihat informasi singkat, manfaat, dan fakta menarik dari tanaman yang kamu temui.',
                  isLocked: true,
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.book,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  title: 'Plant Entry',
                  desc: 'Kumpulkan data tanaman yang sudah pernah kamu scan dan bangun koleksi pribadimu.',
                  isLocked: true,
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.map_outlined,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  title: 'Jelajahi Alam',
                  desc: 'Temukan tanaman unik di sekitarmu dan catat lokasi penemuanmu.',
                  isLocked: true,
                ),
                const SizedBox(height: 32),

                // Notify Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_outlined),
                    label: const Text('Beritahu Saya Ketika Rilis'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔔 Kamu akan dinotifikasi saat fitur ini rilis!'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
  final bool isLocked;

  const _FeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.desc,
    this.isLocked = false,
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
        if (isLocked)
          Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade400),
      ]),
    );
  }
}
