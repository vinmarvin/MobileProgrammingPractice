import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/timer_provider.dart';
import 'youtube_player_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Map<String, String>> _articles = [
    {'title': '5 Cara Menjaga Fokus Saat WFH', 'category': 'Produktivitas', 'emoji': '🧠', 'color': '0xFF1976D2', 'desc': 'Temukan cara efektif menjaga konsentrasi di rumah dengan teknik proven dari para ahli.'},
    {'title': 'Kenapa Istirahat Itu Penting?', 'category': 'Wellbeing', 'emoji': '😌', 'color': '0xFF388E3C', 'desc': 'Tubuh dan pikiran butuh jeda. Pelajari sains di balik pentingnya rest agar lebih produktif.'},
    {'title': 'Digital Detox 7 Hari', 'category': 'Lifestyle', 'emoji': '📵', 'color': '0xFF7B1FA2', 'desc': 'Panduan lengkap menjalankan detox digital selama seminggu untuk kesehatan mental yang lebih baik.'},
    {'title': 'Manfaat Berjalan Kaki 30 Menit', 'category': 'Kesehatan', 'emoji': '🚶', 'color': '0xFFE64A19', 'desc': 'Jalan kaki adalah olahraga paling accessible. Ketahui manfaat luar biasanya untuk tubuhmu.'},
    {'title': 'Teknik Pomodoro untuk Pemula', 'category': 'Produktivitas', 'emoji': '🍅', 'color': '0xFFF57F17', 'desc': 'Kelola waktu lebih baik dengan teknik Pomodoro yang terbukti meningkatkan produktivitas.'},
    {'title': 'Mindfulness dalam 5 Menit', 'category': 'Meditasi', 'emoji': '🧘', 'color': '0xFF00838F', 'desc': 'Kamu tidak perlu berjam-jam untuk meditasi. Pelajari mindfulness singkat yang powerful.'},
  ];

  static const List<Map<String, String>> _videos = [
    {'id': 'GQyWIur03aw', 'title': 'Reset Fokus 5 Menit', 'category': 'Fokus', 'duration': '05:00'},
    {'id': '5MgBikgcWnY', 'title': 'Motivasi Singkat untuk Memulai Hari', 'category': 'Mindset', 'duration': '18:22'},
    {'id': 'inpok4MKVLM', 'title': 'Meditasi 5 Menit untuk Melepas Lelah', 'category': 'Meditasi', 'duration': '05:00'},
    {'id': '5qap5aO4i9A', 'title': 'Lo-fi untuk kerja lebih lama', 'category': 'Ambient', 'duration': 'LIVE'},
  ];

  int _selectedVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timer = context.read<TimerProvider>();
      timer.addListener(_onTimerChanged);
      timer.setPointsAwarder((points, minutes) async {
        final uid = context.read<AuthProvider>().firebaseUser?.uid;
        if (uid != null) {
          await context.read<UserProvider>().addPoints(uid, points, minutes);
        }
      });
    });
  }

  void _onTimerChanged() {
    final timer = context.read<TimerProvider>();
    if (timer.showOverloadDialog && mounted) {
      timer.dismissOverloadDialog();
      _showOverloadAlertDialog();
    }
  }

  void _showOverloadAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Text('⚠️', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Flexible(child: Text('Kamu Sudah 3 Jam Fokus!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
          content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bekerja tanpa henti selama 3 jam dapat menurunkan produktivitas dan merusak kesehatan. Tubuhmu membutuhkan istirahat yang cukup.', style: TextStyle(height: 1.5)),
            SizedBox(height: 12),
            Text('🌿 Ambil jeda 20–30 menit sekarang.', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
          ]),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.self_improvement),
                label: const Text('Istirahat Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<TimerProvider>().stop();
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    context.read<TimerProvider>().removeListener(_onTimerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF2E7D32),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Selamat datang,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(user?.name ?? '...', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.4))),
                          child: Row(children: [
                            const Text('⭐', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text('${user?.points ?? 0} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(user: user),
                    const SizedBox(height: 20),

                    // ── Focus Timer Card ─────────────────────────────────────
                    const _FocusTimerCard(),
                    const SizedBox(height: 16),

                    // ── Music Player (Retro) ─────────────────────────────────
                    const _RetroMusicPlayer(),
                    const SizedBox(height: 24),

                    // ── Artikel ──────────────────────────────────────────────
                    Text('Bacaan Rekomendasi Untuk Meningkatkan Wellbeingmu', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _articles.length,
                        itemBuilder: (ctx, i) => _ArticleCard(article: _articles[i]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Video Rekomendasi ─────────────────────────────────────
                    Text('Tontonan Rekomendasi untuk Fokus dan Relaksasi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Pilih video favoritmu seperti membaca artikel rekomendasi.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _videos.length,
                        itemBuilder: (ctx, i) => _VideoThumbnailCard(
                          video: _videos[i],
                          isSelected: i == _selectedVideoIndex,
                          onTap: () => setState(() => _selectedVideoIndex = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _YoutubeOpenCard(video: _videos[_selectedVideoIndex]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final dynamic user;
  const _StatsRow({this.user});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatCard(label: 'Total Poin', value: '${user?.points ?? 0}', icon: '⭐', color: const Color(0xFFFFF8E1), textColor: const Color(0xFFE65100))),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'Menit Fokus', value: '${user?.totalFocusMinutes ?? 0}', icon: '⏱️', color: const Color(0xFFE3F2FD), textColor: const Color(0xFF0D47A1))),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'Role', value: user?.role ?? '-', icon: '🏅', color: const Color(0xFFF3E5F5), textColor: const Color(0xFF4A148C))),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final Color color, textColor;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11), maxLines: 1),
      ]),
    );
  }
}

// ─── Focus Timer Card ─────────────────────────────────────────────────────────
class _FocusTimerCard extends StatelessWidget {
  const _FocusTimerCard();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final theme = Theme.of(context);

    final isRunning = timer.state == TimerState.running;
    final isStopped = timer.state == TimerState.stopped;
    final isIdle = timer.state == TimerState.idle;
    final isRest = timer.isRestMode;

    // Warna ring
    final Color ringColor;
    final Color restRingColor = Colors.teal.shade500;
    if (isRest) {
      ringColor = restRingColor;
    } else {
      switch (timer.statusLabel) {
        case 'overload': ringColor = Colors.red.shade600; break;
        case 'long_break': ringColor = const Color(0xFF1B5E20); break;
        default: ringColor = const Color(0xFF4CAF50);
      }
    }

    final targetLabel = timer.formatTarget();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header
          Row(children: [
            const Text('⏱️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Focus Timer', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (timer.statusLabel == 'overload') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text('OVERLOAD', style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
            IconButton(
              icon: Icon(timer.isSoundEnabled ? Icons.volume_up : Icons.volume_off, color: Colors.grey.shade600),
              onPressed: () => context.read<TimerProvider>().toggleSound(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),

          // Session progress bar
          const SizedBox(height: 12),
          if (!isIdle) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Progres sesi', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('${(timer.sessionProgress * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: timer.sessionProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Ring + waktu
          Center(
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: timer.progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                ),
              ),
              Column(children: [
                // Mode badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRest ? Colors.teal.shade50 : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isRest ? '😌 REST' : '🎯 FOKUS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isRest ? Colors.teal.shade700 : const Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timer.formattedTime,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: isRest ? Colors.teal.shade700 : (timer.statusLabel == 'overload' ? Colors.red.shade700 : null)),
                ),
                Text(
                  isRest ? 'Sisa istirahat' : 'Sisa: $targetLabel',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // 20-20-2 info banner
          if (isRest) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
              child: Row(children: [
                Text('👁️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Istirahat Mata – Prinsip 20-20-2', style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Lihat benda sejauh 6 meter selama 20 detik untuk pulihkan matamu!', style: TextStyle(color: Colors.teal.shade700, fontSize: 11, height: 1.3)),
                ])),
              ]),
            ),
            const SizedBox(height: 12),
          ],

          // Target selector (hanya saat idle)
          if (isIdle) ...[
            Row(children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('Target: $targetLabel', style: const TextStyle(fontSize: 13)),
            ]),
            Slider(
              value: timer.targetMinutes.toDouble(),
              min: 60,
              max: 480,
              divisions: 14,
              label: targetLabel,
              activeColor: const Color(0xFF2E7D32),
              onChanged: (val) => context.read<TimerProvider>().setTarget(val),
            ),
          ],

          const SizedBox(height: 8),

          // Tombol kontrol
          Row(children: [
            if (isIdle || isStopped)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(isStopped ? 'Lanjut' : 'Mulai'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                  onPressed: () => context.read<TimerProvider>().start(),
                ),
              ),
            if (isRunning)
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2E7D32), side: const BorderSide(color: Color(0xFF2E7D32))),
                  onPressed: () => context.read<TimerProvider>().stop(),
                ),
              ),
            if (isStopped || isRunning) ...[
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Selesai'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  onPressed: () async {
                    final result = await context.read<TimerProvider>().finish();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('🎉 Sesi selesai! +${result['points']} poin diperoleh'),
                        backgroundColor: Colors.green.shade700,
                      ));
                    }
                  },
                ),
              ),
            ],
            if (isStopped) ...[
              const SizedBox(width: 10),
              IconButton(icon: const Icon(Icons.refresh), onPressed: () => context.read<TimerProvider>().reset(), tooltip: 'Reset'),
            ],
          ]),

          // Status text
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              timer.state == TimerState.idle
                  ? '⚡ Pilih durasi & mulai sesi fokusmu'
                  : timer.isRestMode && timer.state == TimerState.running
                      ? '😌 Istirahat sebentar – matamu butuh jeda!'
                      : '+${timer.earnedPoints} poin terkumpul sejauh ini',
              textAlign: TextAlign.center,
              style: TextStyle(color: isRest ? Colors.teal.shade600 : const Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Retro Music Player ───────────────────────────────────────────────────────
class _RetroMusicPlayer extends StatelessWidget {
  const _RetroMusicPlayer();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final vibe = kMusicVibes[timer.selectedVibeIndex];
    final isPlaying = timer.isAudioPlaying;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4)),
              ),
              child: const Text('📻', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Radio Musik Fokus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(isPlaying ? '▶ Sedang diputar' : '■ Siap diputar', style: TextStyle(color: isPlaying ? const Color(0xFF4CAF50) : Colors.white54, fontSize: 11)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPlaying ? const Color(0xFF4CAF50).withOpacity(0.2) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isPlaying ? const Color(0xFF4CAF50) : Colors.white30),
              ),
              child: Text(isPlaying ? 'LIVE' : 'OFF', style: TextStyle(color: isPlaying ? const Color(0xFF4CAF50) : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ]),

          const SizedBox(height: 20),

          // Now Playing
          Row(children: [
            // Vinyl disk animation placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F3460),
                border: Border.all(color: const Color(0xFF4CAF50), width: 2),
              ),
              child: Center(child: Text(vibe['emoji']!, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vibe['label']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 2),
              Text('Focus • Loop mode aktif', style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 6),
              // Equalizer bars (decorative)
              if (isPlaying)
                Row(children: List.generate(12, (i) {
                  final heights = [8.0, 14.0, 10.0, 18.0, 12.0, 20.0, 8.0, 16.0, 12.0, 10.0, 18.0, 14.0];
                  return Container(
                    width: 3,
                    height: heights[i % heights.length],
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }))
              else
                Text('Tekan ▶ untuk mulai', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
            // Controls
            Column(children: [
              GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    await timer.pauseAudio();
                  } else {
                    await timer.playVibeStandalone(timer.selectedVibeIndex);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50),
                    boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.5), blurRadius: 12)],
                  ),
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
                ),
              ),
            ]),
          ]),

          const SizedBox(height: 20),

          // Vibe selector
          const Text('PILIH VIBE', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kMusicVibes.length,
              itemBuilder: (ctx, i) {
                final v = kMusicVibes[i];
                final isSelected = i == timer.selectedVibeIndex;
                return GestureDetector(
                  onTap: () async {
                    if (isSelected && isPlaying) {
                      await timer.pauseAudio();
                    } else {
                      await timer.playVibeStandalone(i);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.2) : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(v['emoji']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(v['label']!, style: TextStyle(color: isSelected ? const Color(0xFF4CAF50) : Colors.white60, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Video Thumbnail Card ─────────────────────────────────────────────────────
class _VideoThumbnailCard extends StatelessWidget {
  final Map<String, String> video;
  final bool isSelected;
  final VoidCallback onTap;
  const _VideoThumbnailCard({required this.video, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            Image.network(
              'https://img.youtube.com/vi/${video['id']!}/hqdefault.jpg',
              height: 140, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 140, color: const Color(0xFFE8F5E9), alignment: Alignment.center, child: const Icon(Icons.play_circle_fill, color: Color(0xFF2E7D32), size: 40)),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.25))),
            Positioned(left: 8, top: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text(video['category']!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
            )),
            Positioned(right: 8, bottom: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text(video['duration']!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
            )),
            if (isSelected) Positioned(right: 8, top: 8, child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            )),
            Positioned.fill(child: Center(child: Icon(Icons.play_circle_outline, color: Colors.white.withOpacity(0.85), size: 36))),
          ]),
        ),
      ),
    );
  }
}

// ─── YouTube Open Card ────────────────────────────────────────────────────────
class _YoutubeOpenCard extends StatelessWidget {
  final Map<String, String> video;
  const _YoutubeOpenCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://img.youtube.com/vi/${video['id']!}/default.jpg',
              width: 80, height: 55, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 80, height: 55, color: const Color(0xFFE8F5E9), child: const Icon(Icons.play_circle_fill, color: Color(0xFF2E7D32))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(video['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${video['category']} • ${video['duration']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ])),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YoutubePlayerScreen(
                    videoId: video['id']!,
                    title: video['title']!,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.play_arrow, size: 16),
              SizedBox(width: 4),
              Text('Lihat', style: TextStyle(fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Article Card ─────────────────────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final Map<String, String> article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(article['color']!));
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(article['title']!),
              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(article['category']!, style: TextStyle(color: color, fontSize: 12)),
                ),
                const SizedBox(height: 12),
                Text(article['desc']!),
              ]),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article['emoji']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                child: Text(article['category']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              Text(article['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      ),
    );
  }
}
