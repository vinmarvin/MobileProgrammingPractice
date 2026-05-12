import 'package:flutter/material.dart';
import '../../models/focus_model.dart';
import '../../services/database_helper.dart';
import '../../core/theme.dart';

class FocusHistoryScreen extends StatefulWidget {
  const FocusHistoryScreen({super.key});

  @override
  State<FocusHistoryScreen> createState() => _FocusHistoryScreenState();
}

class _FocusHistoryScreenState extends State<FocusHistoryScreen> {
  List<FocusHistory> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllFocusHistory();
    setState(() {
      _historyList = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistory(int id) async {
    await DatabaseHelper.instance.deleteFocusHistory(id);
    _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat dihapus')),
      );
    }
  }

  Future<void> _showEditDialog(FocusHistory history) async {
    final nameCtrl = TextEditingController(text: history.taskName);
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Catatan Fokus'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama Kegiatan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                if (newName.isNotEmpty) {
                  final updated = FocusHistory(
                    id: history.id,
                    taskName: newName,
                    durationMinutes: history.durationMinutes,
                    date: history.date,
                    categoryId: history.categoryId,
                  );
                  await DatabaseHelper.instance.updateFocusHistory(updated);
                  if (mounted) Navigator.pop(context);
                  _loadHistory();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Fokus'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat fokus.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.backgroundGreenLight,
                          child: const Icon(Icons.timer, color: AppColors.primaryDark),
                        ),
                        title: Text(
                          item.taskName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Durasi: \${item.durationMinutes} menit'),
                            Text(
                              'Kategori: \${item.categoryName ?? "Lainnya"} | \${item.date}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(item);
                            } else if (value == 'delete') {
                              _deleteHistory(item.id!);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Nama'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
