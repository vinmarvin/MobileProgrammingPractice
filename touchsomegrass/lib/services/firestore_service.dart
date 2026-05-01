import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/community_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USERS ────────────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> addPointsAndMinutes(
      String uid, int addedPoints, int addedMinutes) async {
    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(addedPoints),
      'totalFocusMinutes': FieldValue.increment(addedMinutes),
    });
  }

  Future<void> deductPoints(String uid, int cost) async {
    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(-cost),
    });
  }

  // ─── COMMUNITIES ─────────────────────────────────────────────────────────

  Future<List<CommunityModel>> getCommunities() async {
    final snapshot = await _db.collection('communities').get();
    return snapshot.docs
        .map((doc) => CommunityModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<CommunityModel>> communitiesStream() {
    return _db.collection('communities').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => CommunityModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> seedCommunities() async {
    final snapshot = await _db.collection('communities').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final communities = [
      {
        'name': 'Komunitas Hiking Surabaya',
        'description':
            'Komunitas pecinta hiking dan alam terbuka di Surabaya dan sekitarnya.',
        'category': 'Outdoor',
        'whatsappLink': 'https://wa.me/6281234567890',
        'imageUrl': 'https://picsum.photos/seed/hiking/400/300',
      },
      {
        'name': 'Yoga & Mindfulness ITS',
        'description':
            'Kelas yoga dan meditasi mindfulness untuk mahasiswa dan civitas ITS.',
        'category': 'Wellness',
        'whatsappLink': 'https://wa.me/6281234567891',
        'imageUrl': 'https://picsum.photos/seed/yoga/400/300',
      },
      {
        'name': 'Komunitas Baca Buku Surabaya',
        'description':
            'Diskusi buku bulanan dan rekomendasi bacaan bersama.',
        'category': 'Literasi',
        'whatsappLink': 'https://wa.me/6281234567892',
        'imageUrl': 'https://picsum.photos/seed/books/400/300',
      },
      {
        'name': 'Digital Detox Community',
        'description':
            'Komunitas yang mendukung gaya hidup sehat dengan mengurangi ketergantungan gadget.',
        'category': 'Wellbeing',
        'whatsappLink': 'https://wa.me/6281234567893',
        'imageUrl': 'https://picsum.photos/seed/detox/400/300',
      },
      {
        'name': 'Komunitas Lari Pagi Sidoarjo',
        'description':
            'Lari bersama setiap weekend pagi hari di area Sidoarjo.',
        'category': 'Olahraga',
        'whatsappLink': 'https://wa.me/6281234567894',
        'imageUrl': 'https://picsum.photos/seed/running/400/300',
      },
      {
        'name': 'Produktivitas & Study Group',
        'description':
            'Belajar dan bekerja bersama dengan metode Pomodoro dan deep work.',
        'category': 'Produktivitas',
        'whatsappLink': 'https://wa.me/6281234567895',
        'imageUrl': 'https://picsum.photos/seed/study/400/300',
      },
    ];

    final batch = _db.batch();
    for (final community in communities) {
      final ref = _db.collection('communities').doc();
      batch.set(ref, community);
    }
    await batch.commit();
  }
}
