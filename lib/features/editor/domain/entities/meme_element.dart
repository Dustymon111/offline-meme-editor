import 'package:hive/hive.dart';

part 'meme_element.g.dart';

@HiveType(typeId: 1)
enum MemeElementType {
  @HiveField(0)
  text,

  @HiveField(1)
  sticker,
}

@HiveType(typeId: 2)
class MemeElement {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final MemeElementType type;

  @HiveField(2)
  final double x;

  @HiveField(3)
  final double y;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final double? scale;

  MemeElement({
    this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.content,
    this.scale = 1.0,
  });

  factory MemeElement.fromJson(Map<String, dynamic> json) {
    return MemeElement(
      id: json['id'],
      type: json['type'] == 'text'
          ? MemeElementType.text
          : MemeElementType.sticker,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      content: json['content'],
      scale: (json['scale'] as double).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type == MemeElementType.text ? 'text' : 'sticker',
    'x': x,
    'y': y,
    'content': content,
    'scale': scale,
  };

  MemeElement copyWith({
    String? id,
    MemeElementType? type,
    double? x,
    double? y,
    String? content,
    double? scale,
  }) {
    return MemeElement(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      content: content ?? this.content,
      scale: scale ?? this.scale,
    );
  }
}
