import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'counter_state.dart';
part 'counter_cubit.freezed.dart';

@Singleton()
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState.initial());
}
