/// Lightweight failure types used instead of leaking raw exceptions
/// (SQLiteException, FormatException, etc.) up to the UI layer.
///
/// Presentation code should only ever branch on these, and should show a
/// friendly message ("Something went wrong. Please try again.") while the
/// technical `message` is logged for developers.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A local storage error occurred.']);
}

class DataParsingFailure extends Failure {
  const DataParsingFailure([super.message = 'Could not read the word list.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
