import 'package:equatable/equatable.dart';

/// One entry from the immutable 500-word master vocabulary list.
///
/// This is the domain-layer entity: plain, framework-free, and safe to use
/// throughout the presentation layer. `frequency` is nullable because the
/// spec requires the app to tolerate missing frequency data without
/// inventing numbers.
class QuranWord extends Equatable {
  final int rank;
  final String arabic;
  final String transliteration;
  final String bangla;
  final String english;
  final int? frequency;

  const QuranWord({
    required this.rank,
    required this.arabic,
    required this.transliteration,
    required this.bangla,
    required this.english,
    this.frequency,
  });

  @override
  List<Object?> get props =>
      [rank, arabic, transliteration, bangla, english, frequency];
}
