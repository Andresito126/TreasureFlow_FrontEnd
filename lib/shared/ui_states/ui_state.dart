sealed class UiState<T> {
  const UiState();
}

class UiIdle<T> extends UiState<T> {
  const UiIdle();
}

class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

class UiSuccess<T> extends UiState<T> {
  final T data;
  const UiSuccess(this.data);
}

class UiError<T> extends UiState<T> {
  final String message;
  const UiError(this.message);
}
