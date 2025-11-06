import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_capture_detector/screen_capture_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('screen_capture_detector');
  final detector = ScreenCaptureDetector();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getSdkVersion':
            return 34;
          case 'startDetection':
            return true;
          case 'stopDetection':
            return true;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('startListening returns true', () async {
    final result = await detector.startListening();
    expect(result, isTrue);
  });

  test('stopListening returns true', () async {
    final result = await detector.stopListening();
    expect(result, isTrue);
  });

  test('getSdkVersion returns expected value', () async {
    final isAndroid13OrAbove = await detector.requestPermissions();
    expect(isAndroid13OrAbove, isNotNull);
  });
}
