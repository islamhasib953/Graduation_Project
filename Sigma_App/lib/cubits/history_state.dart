import 'package:segma/models/history_model.dart';

abstract class HistoryState {
  final bool isLoading;
  final String? error;
  final List<History> histories;
  final History? historyToView;

  HistoryState({
    this.isLoading = false,
    this.error,
    this.histories = const [],
    this.historyToView,
  });
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {
  HistoryLoading() : super(isLoading: true);
}

class HistoryLoaded extends HistoryState {
  HistoryLoaded(List<History> histories, {super.historyToView})
      : super(histories: histories);
}

class HistoryUpdated extends HistoryState {
  HistoryUpdated(List<History> histories, {super.historyToView})
      : super(histories: histories);
}

class HistoryError extends HistoryState {
  HistoryError(String message) : super(error: message);
}

class HistoryViewUpdated extends HistoryState {
  HistoryViewUpdated({required super.historyToView, required super.histories});
}