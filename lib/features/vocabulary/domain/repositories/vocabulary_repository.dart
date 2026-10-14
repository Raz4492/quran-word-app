import '../entities/quran_word.dart';
import '../entities/word_progress.dart';
import '../../../../core/constants/app_constants.dart';

/// Contract the presentation layer (cubits) depends on. The implementation
/// lives in the data layer and is the only place that knows about SQLite or
/// the JSON asset — keeping business logic testable and UI-agnostic.
abstract class VocabularyRepository {
  Future<void> initialize();

  Future<List<QuranWord>> getAllWords();
  Future<QuranWord?> getWordByRank(int rank);
  Future<List<QuranWord>> searchWords(String query);

  Future<WordProgress> getProgress(int rank);
  Future<void> saveProgress(WordProgress progress);

  Future<List<LearningWord>> getWordsByStatus(LearningStatus status);
  Future<List<LearningWord>> getDueForReview({int? limit});
  Future<List<LearningWord>> getFavorites();
  Future<List<LearningWord>> getDifficultWords();
  Future<List<int>> getNextNewWordRanks(int count);

  Future<void> toggleFavorite(int rank);
  Future<void> toggleDifficult(int rank);

  Future<Map<LearningStatus, int>> getStatusCounts();
  Future<void> resetAllProgress();
}
