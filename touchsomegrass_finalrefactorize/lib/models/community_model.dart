//Model untuk data komunitas yang nantinya akan dihubungkan dengan Firestore

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String whatsappLink;
  final String imageUrl;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.whatsappLink,
    required this.imageUrl,
  });

  factory CommunityModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      whatsappLink: map['whatsappLink'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://picsum.photos/seed/$id/400/300',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'whatsappLink': whatsappLink,
      'imageUrl': imageUrl,
    };
  }
}
