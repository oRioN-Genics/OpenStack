/// A tiny Result type for success/failure without throwing.
sealed class Result<T> {
  const Result();
  factory Result.ok(T value) = Ok<T>;
  factory Result.err(String message) = Err<T>;
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}
