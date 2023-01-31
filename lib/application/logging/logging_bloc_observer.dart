import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'logger_factory.dart';

@LazySingleton()
class LoggingBlocObserver extends BlocObserver {
  final Logger logger;

  LoggingBlocObserver(
    LoggerFactory loggerFactory,
  ) : logger = loggerFactory.create('LoggingBlocObserver');

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logger.debug(
      'onError',
      {
        'bloc': bloc,
        'error': error,
        'stackTrace': stackTrace,
      },
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    logger.debug(
      'onTransition',
      {
        'bloc': bloc,
        'transition': transition,
      },
    );
    super.onTransition(bloc, transition);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    logger.debug(
      'onChange',
      {
        'bloc': bloc,
        'change': change,
      },
    );

    super.onChange(bloc, change);
  }
}
