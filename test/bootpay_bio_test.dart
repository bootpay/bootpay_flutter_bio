import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bootpay_bio/bootpay_bio.dart';

void main() {
  const MethodChannel channel = MethodChannel('bootpay_bio');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await BootpayBio.platformVersion, '42');
  });
}
