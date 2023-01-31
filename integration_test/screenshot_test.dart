import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:upnp_explorer/application/ioc/ioc.dart';
import 'package:upnp_explorer/domain/device/device.dart';
import 'package:upnp_explorer/infrastructure/upnp/models/device.dart';
import 'package:upnp_explorer/infrastructure/upnp/ssdp_discovery.dart';
import 'package:upnp_explorer/infrastructure/upnp/ssdp_response_message.dart';
import 'package:rxdart/rxdart.dart';

import 'package:upnp_explorer/main.dart' as app;
import 'package:upnp_explorer/presentation/device/widgets/device_list_item.dart';
import 'package:xml/xml.dart';

class Finders {
  static final deviceTile = find.byType(DeviceListItem);
}

class MockSSDPService extends SSDPService {
  @override
  Stream<UPnPDevice> findDevices() {
    final deviceDocument = XmlDocument.parse('''<?xml version="1.0"?>
<root xmlns="urn:schemas-upnp-org:device-1-0"
    configId="configuration number">
    <specVersion>
        <major>2</major>
        <minor>0</minor>
    </specVersion>
    <device>
        <deviceType>urn:schemas-upnp-org:device:deviceType:42</deviceType>
        <friendlyName>Office TV</friendlyName>
        <manufacturer>TVs-R-Us</manufacturer>
        <manufacturerURL>https://www.tvsr.us</manufacturerURL>
        <modelDescription>TV with built in castable</modelDescription>
        <modelName>TV43C</modelName>
        <modelNumber>model number</modelNumber>
        <modelURL>URL to model site</modelURL>
        <serialNumber>42</serialNumber>
        <UDN>uuid:0acdef7e-3cc9-4609-9834-ab1bf9b0466e</UDN>
        <UPC>f6cb4da9-3797-4dfb-92da-0b5b64df1912</UPC>
        <iconList>
        </iconList>
        <serviceList>
            <service>
                <serviceType>urn:schemas-upnp-org:service:serviceType:v</serviceType>
                <serviceId>urn:upnp-org:serviceId:serviceID</serviceId>
                <SCPDURL>URL to service description</SCPDURL>
                <controlURL>URL for control</controlURL>
                <eventSubURL>URL for eventing</eventSubURL>
            </service>
        </serviceList>
        <deviceList>
        </deviceList>
        <presentationURL>URL for presentation</presentationURL>
    </device>
</root>
''');

    final device = DeviceDescription.fromXml(deviceDocument);

    return Stream.fromIterable([
      UPnPDevice(
        DiscoveryResponse('', {
          'cache-control': 'max-age=3600',
          'st': 'urn:dial-multiscreen-org:service:dial:1',
          'usn': 'asdf',
          'ext': '',
          'server': 'TV UPnP/1.0 MiniUPnPd/1.4',
          'location': 'http://192.168.1.100:8060/dial/dd.xml'
        }),
        device,
      ),
    ]).delay(Duration(milliseconds: 500));
  }
}

Future<void> screenshot(WidgetTester tester, String name) async {
  await IntegrationTestWidgetsFlutterBinding.instance
      .convertFlutterSurfaceToImage();
  await tester.pump();
  await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(name);

  return;
}

void main() {
  

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('screenshots', () {
    setUp(() async {
      await configureDependencies(environment: 'tst');

      sl.allowReassignment = true;

      sl.unregister<SSDPService>();
      sl.registerSingleton<SSDPService>(MockSSDPService());
    });

    testWidgets('app launches', (tester) async {
      await tester.pumpWidget(app.MyAppHost());

      await tester.pumpAndSettle();

      expect(Finders.deviceTile, findsOneWidget);

      await screenshot(tester, 'dashboard');
    });
  });
}
