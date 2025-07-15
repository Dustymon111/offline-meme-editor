import 'package:hive/hive.dart';
import 'meme_element.dart';

part 'meme.g.dart';

@HiveType(typeId: 0)
class Meme {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final List<MemeElement> elements;

  Meme({required this.id, required this.imagePath, required this.elements});

  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      id: json['id'],
      imagePath: json['imagePath'],
      elements: (json['elements'] as List)
          .map((e) => MemeElement.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'elements': elements.map((e) => e.toJson()).toList(),
  };
}
