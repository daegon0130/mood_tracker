import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/mood_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/mood_view_model.dart';

class MoodListScreen extends ConsumerWidget {
  const MoodListScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await ref.read(authViewModelProvider.notifier).signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃되었습니다 👋'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.user;
    final moodEntriesAsync = ref.watch(userMoodEntriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'logout':
                  await _showLogoutDialog(context, ref);
                  break;
                case 'profile':
                  // 프로필 화면으로 이동 (추후 구현)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필 기능은 곧 제공될 예정입니다')),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('프로필'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('로그아웃', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (currentUser?.displayName?.isNotEmpty == true
                        ? currentUser!.displayName!.substring(0, 1)
                        : currentUser?.email?.substring(0, 1) ?? 'U')
                    .toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Welcome section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요${currentUser?.displayName?.isNotEmpty == true ? ', ${currentUser!.displayName}님' : ''}!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '오늘의 기분은 어떠신가요?',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mood entries list
          Expanded(
            child: moodEntriesAsync.when(
              data: (moodEntries) {
                if (moodEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '📝',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 기분 기록이 없어요',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '게시물 탭에서 첫 번째 기분을 기록해보세요!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: moodEntries.length,
                  itemBuilder: (context, index) {
                    final moodEntry = moodEntries[index];
                    return MoodEntryCard(moodEntry: moodEntry);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                String errorMessage = '기분 기록을 불러오는데 실패했습니다';
                String suggestion = '';
                Color iconColor = Theme.of(context).colorScheme.error;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: iconColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        if (suggestion.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            suggestion,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // 상태 새로고침
                            ref.invalidate(userMoodEntriesStreamProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MoodEntryCard extends ConsumerWidget {
  final MoodModel moodEntry;

  const MoodEntryCard({
    super.key,
    required this.moodEntry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletingMoodId = ref.watch(moodDeletionProvider);
    final isDeleting = deletingMoodId == moodEntry.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onLongPress: () => _showDeleteDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood emoji
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    moodEntry.mood,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and time
                    Text(
                      DateFormat('yyyy년 M월 d일 HH:mm')
                          .format(moodEntry.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      moodEntry.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    // Mood name
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        MoodEmojis.moodDescriptions[moodEntry.mood] ?? '알 수 없음',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator during deletion
              if (isDeleting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('기분 기록 삭제'),
          content: const Text('이 기분 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // 삭제 중 상태 설정
                ref.read(moodDeletionProvider.notifier).state = moodEntry.id;

                final success = await ref
                    .read(currentUserMoodListProvider.notifier)
                    .deleteMood(moodEntry.id);

                // 삭제 상태 해제
                ref.read(moodDeletionProvider.notifier).state = null;

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('기분 기록이 삭제되었습니다'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('기분 기록 삭제에 실패했습니다'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
