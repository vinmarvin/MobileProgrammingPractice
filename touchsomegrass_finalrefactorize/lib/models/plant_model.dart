class DiscoveredPlant {
  final int? id;
  final String name;
  final String latinName;   // Nama ilmiah / latin
  final String benefits;    // Manfaat tanaman
  final double confidence;
  final String city;            // Kota penemuan (dari geocoding)
  final String discoveredAt;    // Format: 'dd MMM yyyy • HH:mm'
  final String? imagePath;

  DiscoveredPlant({
    this.id,
    required this.name,
    this.latinName = 'Spesies tidak dikenal',
    this.benefits = 'Informasi belum tersedia.',
    required this.confidence,
    required this.city,
    required this.discoveredAt,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'latin_name': latinName,
        'benefits': benefits,
        'confidence': confidence,
        'city': city,
        'discovered_at': discoveredAt,
        'image_path': imagePath,
      };

  factory DiscoveredPlant.fromMap(Map<String, dynamic> map) => DiscoveredPlant(
        id: map['id'] as int?,
        name: map['name'] as String,
        latinName: (map['latin_name'] as String?) ?? 'Spesies tidak dikenal',
        benefits: (map['benefits'] as String?) ?? 'Informasi belum tersedia.',
        confidence: (map['confidence'] as num).toDouble(),
        city: (map['city'] as String?) ?? 'Lokasi tidak diketahui',
        discoveredAt: (map['discovered_at'] as String?) ?? '',
        imagePath: map['image_path'] as String?,
      );

  // Backward-compat: old rows yang masih pakai kolom lama
  // (date_discovered / location) bisa jatuh ke fromMapLegacy
  factory DiscoveredPlant.fromMapLegacy(Map<String, dynamic> map) => DiscoveredPlant(
        id: map['id'] as int?,
        name: map['name'] as String,
        latinName: (map['latin_name'] as String?) ?? 'Spesies tidak dikenal',
        benefits: (map['benefits'] as String?) ?? 'Informasi belum tersedia.',
        confidence: (map['confidence'] as num).toDouble(),
        city: (map['city'] as String?) ??
              (map['location'] as String?) ??
              'Lokasi tidak diketahui',
        discoveredAt: (map['discovered_at'] as String?) ??
                      (map['date_discovered'] as String?) ??
                      '',
        imagePath: map['image_path'] as String?,
      );
}
