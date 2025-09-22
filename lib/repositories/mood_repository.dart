import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';
import '../providers/firebase_providers.dart';

class MoodRepository {
  final FirebaseFirestore _firestore;
  static const String moodCollection = 'mood_entries';

  MoodRepository(this._firestore);

  // 무드 항목 생성
  Future<void> createMoodEntry({
    required String userId,
    required String mood,
    required String description,
  }) async {
    try {
      final moodEntry = MoodModel(
        id: '', // Firestore에서 자동 생성됨
        userId: userId,
        mood: mood,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(moodCollection).add(moodEntry.toMap());
    } catch (e) {
      throw Exception('무드 항목 생성에 실패했습니다: $e');
    }
  }

  // 특정 사용자의 무드 항목들을 스트림으로 가져오기
  Stream<List<MoodModel>> getUserMoodEntriesStream(String userId) {
    try {
      return _firestore
          .collection(moodCollection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final entries = snapshot.docs.map((doc) {
          return MoodModel.fromFirestore(doc);
        }).toList();

        // 날짜순 정렬 (최신순)
        entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return entries;
      }).handleError((error, stackTrace) {
        print('스트림 에러 발생: $error');
        print('스택 트레이스: $stackTrace');

        throw Exception('무드 항목을 가져오는데 실패했습니다: $error');
      });
    } catch (e) {
      print('스트림 생성 중 예외 발생: $e');
      throw Exception('무드 항목 스트림 생성에 실패했습니다: $e');
    }
  }

  // 특정 사용자의 무드 항목들을 한 번만 가져오기
  Future<List<MoodModel>> getUserMoodEntries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(moodCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return MoodModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('무드 항목을 가져오는데 실패했습니다: $e');
    }
  }

  // 무드 항목 삭제
  Future<void> deleteMoodEntry(String moodEntryId) async {
    try {
      await _firestore.collection(moodCollection).doc(moodEntryId).delete();
    } catch (e) {
      throw Exception('무드 항목 삭제에 실패했습니다: $e');
    }
  }

  // 무드 항목 수정
  Future<void> updateMoodEntry({
    required String moodEntryId,
    String? mood,
    String? description,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (mood != null) updateData['mood'] = mood;
      if (description != null) updateData['description'] = description;

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();

        await _firestore
            .collection(moodCollection)
            .doc(moodEntryId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('무드 항목 수정에 실패했습니다: $e');
    }
  }

  // 특정 무드 항목 가져오기
  Future<MoodModel?> getMoodEntry(String moodEntryId) async {
    try {
      final doc =
          await _firestore.collection(moodCollection).doc(moodEntryId).get();

      if (doc.exists) {
        return MoodModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('무드 항목을 가져오는데 실패했습니다: $e');
    }
  }

  // 날짜별 무드 항목 가져오기 -> 나중에
  Future<List<MoodModel>> getMoodEntriesByDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection(moodCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return MoodModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('날짜별 무드 항목을 가져오는데 실패했습니다: $e');
    }
  }

  // 환영 무드 기록 생성
  Future<void> createWelcomeMoodEntry(String userId) async {
    try {
      // 이미 무드 기록이 있는지 확인
      final existingEntries = await _firestore
          .collection(moodCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingEntries.docs.isEmpty) {
        // 환영 무드 기록 생성
        await _firestore.collection(moodCollection).add({
          'userId': userId,
          'mood': '🎉',
          'description': '기분 추적기에 오신 것을 환영합니다! 첫 번째 기록이에요.',
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('환영 무드 기록 생성 완료');
      }
    } catch (e) {
      print('환영 무드 기록 생성 실패: $e');
      // 환영 기록 실패는 전체 플로우를 중단하지 않음
    }
  }
}

// Mood Repository Provider
final moodProvider = Provider<MoodRepository>((ref) {
  return MoodRepository(ref.read(firestoreProvider));
});
