# Quran 500 — Quranic Vocabulary Learning App

A Flutter app for learning the Top 500 Most Frequent Words in the Quran
through flashcards, spaced repetition, daily lessons, review, and quizzes.
Built offline-first in Clean Architecture with a Cubit (flutter_bloc) state
layer and SQLite for progress.

## Data source & accuracy

The 500-word dataset (`assets/data/quran_500_words.json`) was assembled from
two sources you provided:

- **Rank, Arabic script, transliteration, and Bangla meaning** — taken
  verbatim from your word list.
- **Frequency counts** — extracted programmatically (via script, not typed
  by hand) from the [Hafiz Quran Top 500 Words
  page](https://hafiz-quran.com/top-500-words-in-the-quran) you referenced,
  so the numbers match that source exactly.
- **English meanings** — translated from the Bangla meanings you supplied
  and cross-checked against the English glosses on the same reference page.

Before the JSON was written, an automated check confirmed:
- exactly 500 entries
- ranks are exactly `1..500` with **no gaps, duplicates, or reordering**
- no empty/missing required field
- `frequency` is left `null` rather than invented wherever a source didn't
  give one (none were missing here, but the field and the model both support it)

The same integrity rules are re-checked **at runtime** in
`VocabularyLocalDataSource` (as an `assert`) and **in CI/test** via
`test/dataset_integrity_test.dart`, so a future hand-edit that breaks the
ranking or duplicates a word will fail loudly instead of silently shipping.

If you spot a transliteration or meaning you'd word differently, the fix is
a one-line edit to `assets/data/quran_500_words.json` — nothing else in the
app needs to change.

## What's implemented (Phases 1–3 of your spec)

- **500-word dataset** loaded from JSON, mirrored into SQLite on first launch
- **Clean Architecture**: `domain` (entities, repository interfaces) →
  `data` (models, datasources, repository impl) → `presentation`
  (Cubit + pages), per feature folder
- **SQLite schema**: `words`, `word_progress`, `daily_sessions`, `settings`
  (exactly as specified in §33)
- **Spaced repetition**: SM-2-inspired engine
  (`lib/features/learning/domain/spaced_repetition.dart`) driving
  New → Learning → Review → Mastered, prioritizing wrong answers, due
  reviews, difficult words, then recent/new words
- **Flashcards**: flip-to-reveal card, swipe gestures (left=Again,
  right=Good, up=Easy) *and* visible buttons, 5 rotating practice modes
  (Arabic→Meaning, Meaning→Arabic, Arabic Recognition, Transliteration,
  Bangla)
- **Home dashboard**: today's goal + progress bar, Continue Learning,
  Review Due, a rotating Daily Mission
- **Review screen**: Due Today, Difficult Words, Mistakes, Recently Learned,
  Mastered counts, each tappable into a targeted session
- **Browse all 500 words**: search (Arabic/transliteration/Bangla/English/
  rank) + status/favorite/difficult filters
- **Word detail screen**: full stats (times reviewed, accuracy, last/next
  review), Favorite ⭐ / Difficult toggles, "Quran examples coming soon"
  placeholder (no fabricated verses — see §18), Listen button stubbed for
  future audio (§19)
- **Quiz mode**: Easy (Arabic→English) / Medium (Arabic→Bangla) / Hard
  (Meaning→Arabic) with results screen and "words to review"
- **Progress dashboard**: progress ring, status breakdown, accuracy, streak
- **Streak tracking**: gap-tolerant, no guilt-based copy (§10)
- **Local notifications**: daily learning + review reminders, fully
  configurable, zero network required (§11)
- **Settings**: language (বাংলা/English), daily goal, dark mode, text size,
  sound/haptics/reduce-animations, notification times, **Reset Progress**
  behind a confirmation dialog that never fires implicitly
- **Onboarding**: 4 screens → straight into the first lesson, no account
  required (§34)
- **Light & dark theme**: restrained Islamic palette (deep green accent,
  warm off-white in dark mode), Material 3, rounded cards, large Arabic type
- **Unit tests**: dataset integrity, spaced repetition engine
- **Widget test**: onboarding flow

## What's intentionally deferred (matches your own Phase 4 + "Future
Features" ordering)

Your spec's own **MVP Priority** section (§44) puts Firebase in Phase 4,
after the full learning experience — this build follows that ordering:

- **Firebase** (Analytics / Crashlytics / FCM / Remote Config) — dependencies
  are already in `pubspec.yaml` and `main.dart` has a comment showing exactly
  where to add `Firebase.initializeApp()` behind a try/catch so a missing
  config file never blocks learning. Not wired up by default so the app
  truly requires zero network/config to run.
- **Levels screen** (§23) — the data model supports it
  (`AppConstants.wordsPerLevel`), but there's no dedicated Levels UI yet;
  Browse + filters cover the same ground for now.
- **Achievements screen** (§24) and **Quran Context / audio** (§18–19) —
  structured so they can be added without schema changes, but not built out
  as screens yet.
- **flutter_secure_storage** — added as a dependency per your tech list but
  nothing sensitive exists yet to store in it (no accounts); it's ready for
  a future auth/cloud-sync token.

## Project structure

```
lib/
  core/            constants, theme, error types, SQLite helper,
                   settings (SharedPreferences), local notifications
  features/
    vocabulary/    domain entities + repository, data layer (models,
                   datasources, repo impl), browse + word-detail UI
    learning/      spaced repetition engine, flashcard session Cubit + UI
    review/        review dashboard UI
    quiz/          quiz Cubit + UI
    progress/      progress dashboard Cubit + UI
    settings/      settings Cubit + UI, "More" tab
    home/          home dashboard Cubit + UI
    onboarding/    4-screen onboarding
  app.dart         bottom-nav shell (Home / Learn / Review / Progress / More)
  main.dart        composition root — wires repositories, routes to
                   Onboarding or the main shell
assets/data/
  quran_500_words.json   the master 500-word dataset
test/
  dataset_integrity_test.dart
  spaced_repetition_test.dart
  onboarding_page_test.dart
```

## Running it

This was built and reviewed in an environment without Flutter SDK or
pub.dev network access, so it has **not** been run through
`flutter analyze` / `flutter test` / `flutter build apk` here. Every import
path in the codebase was verified to resolve correctly, and the Dart is
written against stable, well-known flutter_bloc/sqflite APIs — but please
run the usual checks on your machine before shipping:

```bash
# 1. Generate native platform folders (android/, ios/) — not included here
flutter create . --platforms=android,ios

# 2. Install dependencies
flutter pub get

# 3. Verify
flutter analyze
flutter test
flutter build apk --debug

# 4. Run
flutter run
```

If `flutter analyze` turns up anything (most likely: minor API drift if
you're on a flutter_bloc/sqflite version newer than pinned in `pubspec.yaml`),
it should be small, mechanical fixes — the architecture and data flow
underneath won't need to change.

## Extending Firebase later

1. Run `flutterfire configure` to generate `firebase_options.dart`.
2. In `main.dart`, wrap the Firebase init in a try/catch *before*
   `runApp(...)`:
   ```dart
   try {
     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   } catch (_) {
     // Learning still works fully offline — see spec §32.
   }
   ```
3. Add Crashlytics' `FlutterError.onError` hook and Analytics calls where
   useful (e.g. quiz completed, lesson completed) — none of the existing
   Cubits need to change for this.
