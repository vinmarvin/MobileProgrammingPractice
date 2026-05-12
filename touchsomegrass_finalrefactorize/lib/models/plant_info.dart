/// Model untuk satu entri di plant_database.json
class PlantInfo {
  final int id;
  final String commonName;
  final String latinName;
  final String benefits;

  const PlantInfo({
    required this.id,
    required this.commonName,
    required this.latinName,
    required this.benefits,
  });

  factory PlantInfo.fromJson(Map<String, dynamic> json) => PlantInfo(
        id: json['id'] as int,
        commonName: json['commonName'] as String,
        latinName: json['latinName'] as String,
        benefits: json['benefits'] as String,
      );

  /// Fallback jika id tidak ada di database
  factory PlantInfo.unknown(int id) => PlantInfo(
        id: id,
        commonName: 'Tanaman Spesies #$id',
        latinName: 'Spesies tidak dikenal',
        benefits: 'Informasi manfaat belum tersedia untuk spesies ini.',
      );
}
