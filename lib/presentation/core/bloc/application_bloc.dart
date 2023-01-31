import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'application_event.dart';
part 'application_state.dart';

@LazySingleton()
class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription? _connectivitySubscription;

  ApplicationBloc() : super(DiscoveryInitial()) {
    on<ConnectivityChanged>(
        (event, emit) => _onConnectivityChanged(event.connectivity, emit));
    _connectivity.checkConnectivity().then((c) => add(ConnectivityChanged(c)));
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((c) => add(ConnectivityChanged(c)));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  void _onConnectivityChanged(
    ConnectivityResult connectivityResult,
    Emitter emit,
  ) {
    if (connectivityResult != ConnectivityResult.wifi) {
      emit(NoNetwork());
    } else if (connectivityResult == ConnectivityResult.wifi) {
      emit(Ready());
    }
  }
}
