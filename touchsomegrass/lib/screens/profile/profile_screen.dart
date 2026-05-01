import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/timer_provider.dart';
import '../redeem/redeem_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _roleCtrl   = TextEditingController();
  bool _isEditing   = false;
  bool _isSaving    = false;

  String _selectedEmoji = '🌿';
  static const List<String> _emojiOptions = [
    '👨‍💻', '☕', '🌿', '🦊', '🎮',
    '🎨', '📚', '🏃', '🧘', '🌸',
  ];

  final _roleOptions = [
    'Member', 'Mahasiswa', 'Karyawan',
    'Freelancer', 'Pengajar', 'Wirausaha',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  void _startEdit(String name, String role, String avatarEmoji) {
    _nameCtrl.text = name;
    _roleCtrl.text = role;
    _selectedEmoji = avatarEmoji;
    setState(() => _isEditing = true);
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) {
      await context.read<UserProvider>().updateProfile(
        uid,
        _nameCtrl.text.trim(),
        _roleCtrl.text.trim(),
        avatarEmoji: _selectedEmoji,
      );
    }

    if (mounted) {
      setState(() {
        _isEditing = false;
        _isSaving  = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profil berhasil diperbarui'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  void _cancelEdit() => setState(() => _isEditing = false);

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<TimerProvider>().reset();
              context.read<UserProvider>().clearUser();
              await context.read<AuthProvider>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          if (!_isEditing && user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  _startEdit(user.name, user.role, user.avatarEmoji),
              tooltip: 'Edit Profil',
            ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // ─── Header ─────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                        child: Column(
                          children: [
                            // ── Avatar Emoji ───────────────────────────────
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              // [BARU] Tampilkan avatarEmoji, bukan inisial huruf
                              child: Center(
                                child: Text(
                                  user.avatarEmoji.isNotEmpty
                                      ? user.avatarEmoji
                                      : '🌿',
                                  style: const TextStyle(fontSize: 44),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(user.role,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.firebaseUser?.email ?? '',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // ─── Stats Card ──────────────────────────────────────
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _StatItem(
                                      label: 'Poin',
                                      value: '${user.points}',
                                      emoji: '⭐'),
                                  _divider(),
                                  _StatItem(
                                      label: 'Menit Fokus',
                                      value: '${user.totalFocusMinutes}',
                                      emoji: '⏱️'),
                                  _divider(),
                                  _StatItem(
                                      label: 'Jam Fokus',
                                      value:
                                          (user.totalFocusMinutes / 60).toStringAsFixed(1),
                                      emoji: '🎯'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ─── Form Edit ─────────────────────────────────
                            if (_isEditing) ...[
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text('Edit Profil',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),

                                        // [BARU] Pemilih emoji horizontal
                                        const Text('Pilih Avatar',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 60,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _emojiOptions.length,
                                            itemBuilder: (_, i) {
                                              final emoji = _emojiOptions[i];
                                              final isSelected =
                                                  emoji == _selectedEmoji;
                                              return GestureDetector(
                                                onTap: () => setState(
                                                    () => _selectedEmoji = emoji),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  margin: const EdgeInsets.only(
                                                      right: 10),
                                                  width: 52,
                                                  height: 52,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(0xFFE8F5E9)
                                                        : Colors.grey.shade100,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF2E7D32)
                                                          : Colors.transparent,
                                                      width: 2.5,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(emoji,
                                                        style: const TextStyle(
                                                            fontSize: 26)),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Nama
                                        TextFormField(
                                          controller: _nameCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Nama Lengkap',
                                            prefixIcon:
                                                Icon(Icons.person_outlined),
                                          ),
                                          validator: (v) =>
                                              v == null || v.trim().isEmpty
                                                  ? 'Nama tidak boleh kosong'
                                                  : null,
                                        ),
                                        const SizedBox(height: 14),

                                        // Role Dropdown
                                        DropdownButtonFormField<String>(
                                          initialValue: _roleOptions.contains(
                                                  _roleCtrl.text)
                                              ? _roleCtrl.text
                                              : _roleOptions.first,
                                          decoration: const InputDecoration(
                                            labelText: 'Role / Status',
                                            prefixIcon:
                                                Icon(Icons.work_outline),
                                          ),
                                          items: _roleOptions
                                              .map((r) => DropdownMenuItem(
                                                  value: r, child: Text(r)))
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null) _roleCtrl.text = v;
                                          },
                                        ),
                                        const SizedBox(height: 20),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: _cancelEdit,
                                                child: const Text('Batal'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed:
                                                    _isSaving ? null : _saveEdit,
                                                child: _isSaving
                                                    ? const SizedBox(
                                                        height: 20, width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : const Text('Simpan'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // ─── Info Display (view mode) ──────────────────
                            if (!_isEditing) ...[
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Informasi Akun',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      const SizedBox(height: 12),
                                      _InfoTile(
                                          icon: Icons.person_outlined,
                                          label: 'Nama',
                                          value: user.name),
                                      const Divider(),
                                      _InfoTile(
                                          icon: Icons.work_outline,
                                          label: 'Role',
                                          value: user.role),
                                      const Divider(),
                                      _InfoTile(
                                          icon: Icons.email_outlined,
                                          label: 'Email',
                                          value:
                                              authProvider.firebaseUser?.email ??
                                                  '-'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ─── [BARU] Tombol Katalog Tukar Poin ────────
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Text('🎁',
                                      style: TextStyle(fontSize: 20)),
                                  label: const Text(
                                    'Katalog Tukar Poin',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RedeemScreen(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // ─── Logout ─────────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout',
                                    style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _confirmLogout,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Footer
                            Center(
                              child: Text(
                                '🌿 TouchSomeGrass v1.5.0\nITS Mobile Programming',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _divider() =>
      Container(height: 40, width: 1, color: Colors.grey.shade200);
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label, value, emoji;
  const _StatItem({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
