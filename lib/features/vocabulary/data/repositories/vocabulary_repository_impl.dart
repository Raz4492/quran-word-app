import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/quran_word.dart';
import '../../domain/entities/word_progress.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../datasources/vocabulary_local_datasource.dart';
import '../models/word_progress_model.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  VocabularyRepositoryImpl({
    VocabularyLocalDataSource? vocabularySource,
    ProgressLocalDataSource? progressSource,
  })  : _vocabularySource = vocabularySource ?? VocabularyLocalDataSource(),
        _progressSource = progressSource ?? ProgressLocalDataSource();

  final VocabularyLocalDataSource _vocabularySource;
  final ProgressLocalDataSource _progressSource;

  List<QuranWord>? _wordCache;

  @override
  Future<void> initialize() async {
    await _vocabularySource.seedDatabaseIfEmpty();
    _wordCache = await _vocabularySource.getAllWordsFromDb();
  }

  Future<List<QuranWord>> _words() async {
    _wordCache ??= await _vocabularySource.getAllWordsFromDb();
    return _wordCache!;
  }

  @override
  Future<List<QuranWord>> getAllWords() => _words();

  @override
  Future<QuranWord?> getWordByRank(int rank) async {
    final words = await _words();
    for (final w in words) {
      if (w.rank == rank) return w;
    }
    return null;
  }

  @override
  Future<List<QuranWord>> searchWords(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final words = await _words();
    final rankQuery = int.tryParse(q);
    return words.where((w) {
      if (rankQuery != null && w.rank == rankQuery) return true;
      return w.arabic.contains(q) ||
          w.transliteration.toLowerCase().contains(q) ||
          w.bangla.toLowerCase().contains(q) ||
          w.english.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<WordProgress> getProgress(int rank) => _progressSource.getProgress(rank);

  @override
  Future<void> saveProgress(WordProgress progress) =>
      _progressSource.saveProgress(WordProgressModel.fromEntity(progress));

  Future<LearningWord?> _join(int rank, WordProgress p) async {
    final w = await getWordByRank(rank);
    if (w == null) return null;
    return LearningWord(w, p);
  }

  @override
  Future<List<LearningWord>> getWordsByStatus(LearningStatus status) async {
    final progresses = await _progressSource.getByStatus(status.toDb());
    final result = <LearningWord>[];
    for (final p in progresses) {
      final lw = await _join(p.wordRank, p);
      if (lw != null) result.add(lw);
    }
    return result;
  }

  @override
  Future<List<LearningWord>> getDueForReview({int? limit}) async {
    final progresses = await _progressSource.getDueForReview(limit: limit);
    final result = <LearningWord>[];
    for (final p in progresses) {
      final lw = await _join(p.wordRank, p);
      if (lw != null) result.add(lw);
    }
    return result;
  }

  @override
  Future<List<LearningWord>> getFavorites() async {
    final progresses = await _progressSource.getFavorites();
    final result = <LearningWord>[];
    for (final p in progresses) {
      final lw = await _join(p.wordRank, p);
      if (lw != null) result.add(lw);
    }
    return result;
  }

  @override
  Future<List<LearningWord>> getDifficultWords() async {
    final progresses = await _progressSource.getDifficult();
    final result = <LearningWord>[];
    for (final p in progresses) {
      final lw = await _join(p.wordRank, p);
      if (lw != null) result.add(lw);
    }
    return result;
  }

  @override
  Future<List<int>> getNextNewWordRanks(int count) =>
      _progressSource.getNewWordRanksInOrder(limit: count);

  @override
  Future<void> toggleFavorite(int rank) async {
    final current = await getProgress(rank);
    await saveProgress(current.copyWith(isFavorite: !current.isFavorite));
  }

  @override
  Future<void> toggleDifficult(int rank) async {
    final current = await getProgress(rank);
    await saveProgress(current.copyWith(isDifficult: !current.isDifficult));
  }

  @override
  Future<Map<LearningStatus, int>> getStatusCounts() async {
    final raw = await _progressSource.statusCounts();
    final total = (await _words()).length;
    final counts = <LearningStatus, int>{
      for (final s in LearningStatus.values) s: raw[s.toDb()] ?? 0,
    };
    // Anything with no progress row at all still counts as "new".
    final accountedFor = counts.values.fold<int>(0, (a, b) => a + b);
    if (accountedFor < total) {
      counts[LearningStatus.newWord] =
          (counts[LearningStatus.newWord] ?? 0) + (total - accountedFor);
    }
    return counts;
  }

  @override
  Future<void> resetAllProgress() async {
    await _progressSource.resetAll();
  }
}
