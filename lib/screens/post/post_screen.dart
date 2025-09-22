import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mood_model.dart';
import '../../providers/app_providers.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/mood_view_model.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final userId = authState.user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    final creationState = ref.watch(currentUserMoodCreationProvider);

    // Listen to description changes
    ref.listen(
        currentUserMoodCreationProvider.select((state) => state.description),
        (prev, next) {
      if (_descriptionController.text != next) {
        _descriptionController.text = next;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('기분 기록하기'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Text(
                      '📝',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '오늘의 기분을 기록해보세요',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '기분과 함께 간단한 설명을 적어주세요',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (creationState.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    creationState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Description input
              Text(
                '설명',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '오늘 하루는 어땠나요? 기분에 대해 자세히 적어주세요...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onChanged: (value) {
                  ref
                      .read(currentUserMoodCreationProvider.notifier)
                      .updateDescription(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '설명을 입력해주세요';
                  }
                  if (value.trim().length < 5) {
                    return '설명은 최소 5자 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Mood selection
              Text(
                '기분 선택',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '오늘의 기분을 선택해주세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 16),

              // Mood buttons grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: MoodEmojis.allMoods.length,
                itemBuilder: (context, index) {
                  final mood = MoodEmojis.allMoods[index];
                  final isSelected = creationState.selectedMood == mood;
                  final moodName = MoodEmojis.moodDescriptions[mood] ?? '';

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentUserMoodCreationProvider.notifier)
                          .selectMood(mood);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moodName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.8),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: creationState.isLoading ? null : _submitMoodEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: creationState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          '게시',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Safe area for bottom navigation
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitMoodEntry() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Submit mood entry using ViewModel
    final success =
        await ref.read(currentUserMoodCreationProvider.notifier).createMood();

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('기분이 성공적으로 기록되었습니다! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      // 홈 탭으로 이동 (IndexedStack 사용 중이므로 탭 인덱스 변경)
      ref.read(selectedTabProvider.notifier).state = 0;
    }
  }
}
