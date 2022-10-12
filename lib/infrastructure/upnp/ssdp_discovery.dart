import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:injectable/injectable.dart';
import 'package:xml/xml.dart';

import '../../application/device/traffic_repository.dart';
import '../../domain/device/device.dart';
import '../../domain/device/device_repository_type.dart';
import '../../domain/device/service_repository_type.dart';
import '../core/download_service.dart';
import '../core/logger_factory.dart';
import 'models/device.dart';
import 'models/service_description.dart';
import 'device_discovery_service.dart';

class SocketOptions {
  final InternetAddress multicastAddress;
  final NetworkInterface interface;
  SocketOptions(this.interface, this.multicastAddress);
}

@Singleton()
class SSDPService {
  StreamController<UPnPDevice> controller =
      StreamController<UPnPDevice>.broadcast();

  final DownloadService download;
  final DeviceDiscoveryService discovery;
  final Logger logger;
  final DeviceRepositoryType deviceRepository;
  final ServiceRepositoryType serviceRepository;
  final TrafficRepository trafficRepository;

  final List<Object> seen = [];

  Stream<UPnPDevice> get stream => controller.stream;

  SSDPService(
    this.discovery,
    this.download,
    LoggerFactory loggerFactory,
    @Named('DeviceRepository') this.deviceRepository,
    @Named('ServiceRepository') this.serviceRepository,
    this.trafficRepository,
  ) : logger = loggerFactory.build('SSDPService');

  _addDevice(Uri root, Device device) async {
    deviceRepository.insert(device);

    for (final service in device.serviceList.services) {
      final downloadUri = new Uri(
        scheme: root.scheme,
        host: root.host,
        port: root.port,
        pathSegments: service.scpdurl.pathSegments,
      );
      try {
        final response = await download.get(downloadUri);

        if (response == null) {
          continue;
        }

        final serviceDescription = ServiceDescription.fromXml(
          XmlDocument.parse(response.body),
        );
        serviceRepository.insert(
          service.serviceId.toString(),
          serviceDescription,
        );
        trafficRepository.add(
          Traffic<Response>(
            response,
            TrafficProtocol.upnp,
            TrafficDirection.incoming,
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
      if (seen.contains(event.message.location)) {
        return;
      }

      seen.add(event.message.location);

      final response = await download.get(event.message.location);

      if (response == null) {
        return;
      }

      final xmlDocument = XmlDocument.parse(response.body);

      final rootDocument = DeviceDescription.fromXml(xmlDocument);

      trafficRepository.add(
        Traffic<Response>(
          response,
          TrafficProtocol.upnp,
          TrafficDirection.incoming,
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

      if (controller.isClosed) {
        return;
      }

      controller.add(device);
    } else if (event is SearchComplete) {
      controller.close();
    }
  }

  Stream<UPnPDevice> findDevices() {
    seen.clear();
    controller = StreamController<UPnPDevice>.broadcast();

    discovery.init().then((_) {
      discovery.responses.listen(
        _onData,
        onDone: () {
          controller.close();
        },
        onError: (err) {
          controller.addError(err);
        },
      );
      discovery.search();
    });

    return stream;
  }
}