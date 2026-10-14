part of 'vocabulary_cubit.dart';

enum BrowseFilter { all, newWord, learning, review, mastered, favorites, difficult }

extension BrowseFilterX on BrowseFilter {
  String get label => switch (this) {
        BrowseFilter.all => 'All',
        BrowseFilter.newWord => 'New',
        BrowseFilter.learning => 'Learning',
        BrowseFilter.review => 'Review',
        BrowseFilter.mastered => 'Mastered',
        BrowseFilter.favorites => 'Favorites',
        BrowseFilter.difficult => 'Difficult',
      };
}

sealed class VocabularyState extends Equatable {
  const VocabularyState();
  @override
  List<Object?> get props => [];
}

class VocabularyLoading extends VocabularyState {
  const VocabularyLoading();
}

class VocabularyError extends VocabularyState {
  final String message;
  const VocabularyError(this.message);
  @override
  List<Object?> get props => [message];
}

class VocabularyLoaded extends VocabularyState {
  final List<LearningWord> allWords;
  final List<LearningWord> visibleWords;
  final BrowseFilter filter;
  final String query;

  const VocabularyLoaded({
    required this.allWords,
    required this.visibleWords,
    this.filter = BrowseFilter.all,
    this.query = '',
  });

  VocabularyLoaded copyWith({
    List<LearningWord>? allWords,
    List<LearningWord>? visibleWords,
    BrowseFilter? filter,
    String? query,
  }) {
    return VocabularyLoaded(
      allWords: allWords ?? this.allWords,
      visibleWords: visibleWords ?? this.visibleWords,
      filter: filter ?? this.filter,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [allWords, visibleWords, filter, query];
}
