import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:injectable/injectable.dart';

import '../../application/logging/logger_factory.dart';

@LazySingleton()
class DownloadService {
  final Logger logger;

  DownloadService(LoggerFactory loggerFactory)
      : logger = loggerFactory.create('DeviceDataService');

  Future<Response?> get(Uri uri) async {
    return download(uri.toString());
  }

  Future<Response?> download(String url) async {
    logger.debug('Downloading $url');

    try {
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    return response;
    } catch (err) {
      logger.error('Unable to download $url: $err');
      return null;
    }
  }
}
