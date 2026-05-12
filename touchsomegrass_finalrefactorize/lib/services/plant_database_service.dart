import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plant_info.dart';

/// Service untuk lookup data tanaman dari plant_database.json (pola Modul 6 CRUD).
/// Database JSON di-load sekali dan di-cache di memori.
class PlantDatabaseService {
  static final PlantDatabaseService _instance = PlantDatabaseService._internal();
  factory PlantDatabaseService() => _instance;
  PlantDatabaseService._internal();

  static const String _assetPath = 'assets/models/plant_database.json';

  Map<int, PlantInfo>? _cache;

  /// Load dan parse plant_database.json dari assets.
  Future<void> init() async {
    if (_cache != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final List<dynamic> list = json.decode(raw);
    _cache = {
      for (final item in list) (item['id'] as int): PlantInfo.fromJson(item)
    };
  }

  /// Cari PlantInfo berdasarkan index output model AIY.
  /// Mengembalikan [PlantInfo.unknown] jika tidak ditemukan.
  PlantInfo lookup(int modelIndex) {
    if (_cache == null) return PlantInfo.unknown(modelIndex);
    return _cache![modelIndex] ?? PlantInfo.unknown(modelIndex);
  }

  bool get isLoaded => _cache != null;
}
