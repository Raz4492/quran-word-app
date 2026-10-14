import '../../domain/entities/quran_word.dart';

/// Data-layer counterpart of [QuranWord] with (de)serialization helpers for
/// both the bundled JSON asset and the SQLite `words` table.
class QuranWordModel extends QuranWord {
  const QuranWordModel({
    required super.rank,
    required super.arabic,
    required super.transliteration,
    required super.bangla,
    required super.english,
    super.frequency,
  });

  factory QuranWordModel.fromJson(Map<String, dynamic> json) {
    return QuranWordModel(
      rank: json['rank'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      bangla: json['bangla'] as String,
      english: json['english'] as String,
      // Left null rather than invented when the source data omits it.
      frequency: json['frequency'] as int?,
    );
  }

  factory QuranWordModel.fromMap(Map<String, dynamic> map) {
    return QuranWordModel(
      rank: map['rank'] as int,
      arabic: map['arabic'] as String,
      transliteration: map['transliteration'] as String,
      bangla: map['bangla'] as String,
      english: map['english'] as String,
      frequency: map['frequency'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'rank': rank,
        'arabic': arabic,
        'transliteration': transliteration,
        'bangla': bangla,
        'english': english,
        'frequency': frequency,
      };
}
