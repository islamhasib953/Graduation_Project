part of 'growth_cubit.dart';

abstract class GrowthState extends Equatable {
  const GrowthState();

  @override
  List<Object?> get props => [];
}

class GrowthInitial extends GrowthState {}

class GrowthLoading extends GrowthState {}

class GrowthLoaded extends GrowthState {
  final List<GrowthRecord> records;
  final GrowthRecord? lastRecord;
  final GrowthChanges changes;

  const GrowthLoaded({
    required this.records,
    required this.lastRecord,
    required this.changes,
  });

  @override
  List<Object?> get props => [records, lastRecord, changes];
}

class GrowthError extends GrowthState {
  final String message;

  const GrowthError({required this.message});

  @override
  List<Object?> get props => [message];
}