import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class PhotoEntry {
  final String path;
  final int twibbonIndex;
  final String? location;

  const PhotoEntry({
    required this.path,
    required this.twibbonIndex,
    this.location,
  });

  bool get hasTwibbon => twibbonIndex >= 0;

  Map<String, dynamic> toJson() => {
    'path': path,
    'twibbonIndex': twibbonIndex,
    'location': location,
  };

  factory PhotoEntry.fromJson(Map<String, dynamic> json) => PhotoEntry(
    path: json['path'] as String,
    twibbonIndex: (json['twibbonIndex'] as int?) ?? 0,
    location: json['location'] as String?,
  );
}

class PickedPhotoData {
  final String path;
  final String? location;
  const PickedPhotoData({required this.path, this.location});
}

const String _kEntriesKey = 'tsg_photo_entries_v2';

class AlbumProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  List<PhotoEntry> _entries = [];
  bool _isLoading = false;

  List<PhotoEntry> get entries    => _entries;
  bool             get isLoading  => _isLoading;

  Future<void> loadPhotos() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_kEntriesKey) ?? [];

    _entries = raw
        .map((s) {
          try {
            return PhotoEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<PhotoEntry>()
        .where((e) => File(e.path).existsSync())
        .toList();

    await _persist();
    _isLoading = false;
    notifyListeners();
  }

  Future<PickedPhotoData?> pickFromCamera() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final savedPath = await _copyToAlbumDir(File(picked.path));
      final location  = await _fetchLocationString();

      return PickedPhotoData(path: savedPath, location: location);
    } catch (e) {
      debugPrint('Camera pick error: $e');
      return null;
    }
  }

  Future<PickedPhotoData?> pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final savedPath = await _copyToAlbumDir(File(picked.path));
      final location  = await _fetchLocationString();

      return PickedPhotoData(path: savedPath, location: location);
    } catch (e) {
      debugPrint('Gallery pick error: $e');
      return null;
    }
  }

  Future<void> savePhotoWithTwibbon({
    required String path,
    required int twibbonIndex,
    String? location,
  }) async {
    final entry = PhotoEntry(
      path: path,
      twibbonIndex: twibbonIndex,
      location: location,
    );
    _entries.insert(0, entry); // terbaru di atas
    await _persist();
    notifyListeners();
  }

  Future<void> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
      _entries.removeWhere((e) => e.path == path);
      await _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<String> _copyToAlbumDir(File source) async {
    final appDir  = await getApplicationDocumentsDirectory();
    final albumDir = Directory('${appDir.path}/tsg_album');
    if (!albumDir.existsSync()) albumDir.createSync(recursive: true);

    final filename = 'tsg_${DateTime.now().millisecondsSinceEpoch}${p.extension(source.path)}';
    final destPath = '${albumDir.path}/$filename';
    await source.copy(destPath);
    return destPath;
  }

  Future<String?> _fetchLocationString() async {
    try {
      // Cek & minta izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      // Konversi koordinat → nama kota (geocoding)
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[
        if (place.subAdministrativeArea?.isNotEmpty == true)
          place.subAdministrativeArea!,
        if (place.administrativeArea?.isNotEmpty == true)
          place.administrativeArea!,
      ];

      return parts.isNotEmpty ? parts.join(', ') : null;
    } catch (e) {
      debugPrint('Geolocation error: $e');
      return null;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kEntriesKey,
      _entries.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
