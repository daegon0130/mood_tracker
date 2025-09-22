import 'package:cloud_firestore/cloud_firestore.dart';

class MoodModel {
  final String id;
  final String userId;
  final String mood; // 이모티콘으로 표현될 기분
  final String description;
  final DateTime createdAt;

  const MoodModel({
    required this.id,
    required this.userId,
    required this.mood,
    required this.description,
    required this.createdAt,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory MoodModel.fromMap(Map<String, dynamic> map, String id) {
    return MoodModel(
      id: id,
      userId: map['userId'] ?? '',
      mood: map['mood'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Firestore DocumentSnapshot에서 데이터를 가져올 때 사용
  factory MoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodModel.fromMap(data, doc.id);
  }

  // Firestore에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mood': mood,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 복사 생성자
  MoodModel copyWith({
    String? id,
    String? userId,
    String? mood,
    String? description,
    DateTime? createdAt,
  }) {
    return MoodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MoodModel(id: $id, userId: $userId, mood: $mood, description: $description, createdAt: $createdAt)';
  }
}

// 기분 이모티콘 상수
class MoodEmojis {
  static const String happy = '😊';
  static const String sad = '😢';
  static const String angry = '😠';
  static const String excited = '🤩';
  static const String calm = '😌';
  static const String anxious = '😰';
  static const String love = '😍';
  static const String neutral = '😐';

  static const List<String> allMoods = [
    happy,
    excited,
    love,
    calm,
    neutral,
    anxious,
    sad,
    angry,
  ];

  // 이모티콘에 대한 설명
  static const Map<String, String> moodDescriptions = {
    happy: '행복',
    sad: '슬픔',
    angry: '화남',
    excited: '신남',
    calm: '평온',
    anxious: '불안',
    love: '사랑',
    neutral: '보통',
  };
}
