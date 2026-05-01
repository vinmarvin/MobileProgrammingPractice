import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

// ─── Model Hadiah Dummy ────────────────────────────────────────────────────────
class _RewardItem {
  final String emoji;
  final String name;
  final String description;
  final int pointCost;
  final Color color;

  const _RewardItem({
    required this.emoji,
    required this.name,
    required this.description,
    required this.pointCost,
    required this.color,
  });
}

const List<_RewardItem> _kRewards = [
  _RewardItem(
    emoji: '☕',
    name: 'Voucher Kopi Nectar',
    description: 'Diskon Rp 15.000 untuk minuman pilihan di Nectar Coffee.',
    pointCost: 150,
    color: Color(0xFF6D4C41),
  ),
  _RewardItem(
    emoji: '🏋️',
    name: 'Diskon Gym 1 Bulan',
    description: 'Potongan 20% biaya membership gym selama 1 bulan.',
    pointCost: 500,
    color: Color(0xFF1565C0),
  ),
  _RewardItem(
    emoji: '📚',
    name: 'E-Book Produktivitas',
    description: 'Akses 1 e-book pilihan dari koleksi wellbeing & produktivitas.',
    pointCost: 80,
    color: Color(0xFF4A148C),
  ),
  _RewardItem(
    emoji: '🍱',
    name: 'Voucher Makan Siang',
    description: 'Gratis 1 paket makan siang di partner restoran terdekat.',
    pointCost: 200,
    color: Color(0xFFE65100),
  ),
  _RewardItem(
    emoji: '🧘',
    name: 'Sesi Meditasi Online',
    description: 'Akses 1 sesi meditasi online bersama instruktur bersertifikat.',
    pointCost: 120,
    color: Color(0xFF00695C),
  ),
  _RewardItem(
    emoji: '🎮',
    name: 'Gift Card Game',
    description: 'Voucher top-up game senilai Rp 10.000 untuk platform pilihan.',
    pointCost: 100,
    color: Color(0xFF1B5E20),
  ),
  _RewardItem(
    emoji: '🧴',
    name: 'Skincare Starter Kit',
    description: 'Paket skincare mini dari brand lokal terpilih.',
    pointCost: 300,
    color: Color(0xFFAD1457),
  ),
  _RewardItem(
    emoji: '🚌',
    name: 'Saldo Transportasi',
    description: 'Top-up saldo angkutan umum (Bus/KRL) senilai Rp 20.000.',
    pointCost: 200,
    color: Color(0xFF0277BD),
  ),
];

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  Future<void> _handleRedeem(
    BuildContext context,
    _RewardItem reward,
    int userPoints,
    String uid,
  ) async {
    if (userPoints < reward.pointCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Poin tidak cukup! Kamu butuh ${reward.pointCost} poin, '
            'saat ini hanya punya $userPoints poin.',
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // Konfirmasi penukaran
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(reward.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(reward.name,
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward.description,
                style: const TextStyle(height: 1.4)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biaya: ${reward.pointCost} poin',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100))),
                      Text('Sisa: ${userPoints - reward.pointCost} poin',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tukar Sekarang'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Kurangi poin di Firestore via UserProvider
    await context.read<UserProvider>().deductPoints(uid, reward.pointCost);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Berhasil menukar ${reward.name}! -${reward.pointCost} poin.',
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final user         = userProvider.user;
    final uid          = authProvider.firebaseUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text('Katalog Tukar Poin'),
        actions: [
          // Tampilkan saldo poin user di AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${user?.points ?? 0} poin',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tukarkan Poinmu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Poin kamu terkumpul dari sesi fokus.\n'
                        'Saldo aktif: ${user?.points ?? 0} poin',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Pilih Hadiah',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // GridView hadiah
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _kRewards.length,
              itemBuilder: (ctx, i) {
                final reward = _kRewards[i];
                final canAfford = (user?.points ?? 0) >= reward.pointCost;

                return _RewardCard(
                  reward: reward,
                  canAfford: canAfford,
                  onTap: () => _handleRedeem(
                    context,
                    reward,
                    user?.points ?? 0,
                    uid,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reward Card Widget ───────────────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final _RewardItem reward;
  final bool canAfford;
  final VoidCallback onTap;

  const _RewardCard({
    required this.reward,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: canAfford ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji + badge stok
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: reward.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(reward.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                  const Spacer(),
                  if (!canAfford)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Kurang',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Nama hadiah
              Text(
                reward.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: canAfford ? Colors.black87 : Colors.grey.shade500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Deskripsi
              Expanded(
                child: Text(
                  reward.description,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),

              // Biaya poin
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford
                      ? reward.color.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.pointCost} poin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? reward.color : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
