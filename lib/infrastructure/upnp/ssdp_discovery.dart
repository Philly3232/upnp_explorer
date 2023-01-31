import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:xml/xml.dart';

import '../../application/logging/logger_factory.dart';
import '../../domain/device/device.dart';
import '../../domain/device/device_repository_type.dart';
import '../../domain/device/service_repository_type.dart';
import '../../domain/network_logs/direction.dart';
import '../../domain/network_logs/network_logs_repository_type.dart';
import '../../domain/network_logs/protocol.dart';
import '../../domain/network_logs/traffic.dart';
import '../core/download_service.dart';
import 'device_discovery_service.dart';
import 'models/device.dart';
import 'models/service_description.dart';

class SocketOptions {
  final InternetAddress multicastAddress;
  final NetworkInterface interface;
  SocketOptions(this.interface, this.multicastAddress);
}

abstract class SSDPService {
  Stream<UPnPDevice> findDevices() {
    return Stream.empty();
  }
}

@LazySingleton(as: SSDPService)
class NetworkSSDPService extends SSDPService {
  StreamController<UPnPDevice> _controller =
      StreamController<UPnPDevice>.broadcast();

  final DownloadService _download;
  final DeviceDiscoveryService _discovery;
  final Logger logger;
  final DeviceRepositoryType _deviceRepository;
  final ServiceRepositoryType _serviceRepository;
  final NetworkLogsRepositoryType _trafficRepository;

  final List<Object> _seen = [];

  Stream<UPnPDevice> get _stream => _controller.stream;

  NetworkSSDPService(
    this._discovery,
    this._download,
    LoggerFactory _loggerFactory,
    @Named('DeviceRepository') this._deviceRepository,
    @Named('ServiceRepository') this._serviceRepository,
    this._trafficRepository,
  ) : logger = _loggerFactory.create('SSDPService');

  _addDevice(Uri root, Device device) async {
    _deviceRepository.insert(device);

    for (final service in device.serviceList.services) {
      final downloadUri = new Uri(
        scheme: root.scheme,
        host: root.host,
        port: root.port,
        pathSegments: service.scpdurl.pathSegments,
      );
      try {
        final response = await _download.get(downloadUri);

        if (response == null) {
          continue;
        }

        final serviceDescription = ServiceDescription.fromXml(
          XmlDocument.parse(response.body),
        );
        _serviceRepository.insert(
          service.serviceId.toString(),
          serviceDescription,
        );
        _trafficRepository.add(
          Traffic(
            message: responseToString(response),
            protocol: Protocol.upnp,
            direction: Direction.incoming,
            origin: response.request!.url.authority,
          ),
        );
      } catch (err) {}
    }

    for (final child in device.deviceList.devices) {
      await _addDevice(root, child);
    }
  }

  _onData(SearchMessage event) async {
    if (event is DeviceFound) {
      if (_seen.contains(event.message.location)) {
        return;
      }

      _seen.add(event.message.location);

      final response = await _download.get(event.message.location);

      if (response == null) {
        return;
      }

      final xmlDocument = XmlDocument.parse(response.body);

      final rootDocument = DeviceDescription.fromXml(xmlDocument);

      _trafficRepository.add(
        Traffic(
          message: responseToString(response),
          protocol: Protocol.upnp,
          direction: Direction.incoming,
          origin: response.request!.url.authority,
        ),
      );

      final device = UPnPDevice(event.message, rootDocument);

      logger.information(
        'Discovered device',
        {
          'friendlyName': device.description.device.friendlyName,
          'model': device.description.device.modelName,
          'manufacturer': device.description.device.manufacturer,
        },
      );

      await _addDevice(event.message.location, device.description.device);

      if (_controller.isClosed) {
        return;
      }

      _controller.add(device);
    } else if (event is SearchComplete) {
      _controller.close();
    }
  }

  Stream<UPnPDevice> findDevices() {
    _seen.clear();
    _controller = StreamController<UPnPDevice>.broadcast();

    _discovery.init().then((_) {
      _discovery.responses.listen(
        _onData,
        onDone: () {
          _controller.close();
        },
        onError: (err) {
          _controller.addError(err);
        },
      );
      _discovery.search();
    });

    return _stream;
  }
}
