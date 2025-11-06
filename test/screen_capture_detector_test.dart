import 'package:flutter_test/flutter_test.dart';
import 'package:screen_capture_detector/screen_capture_detector_platform_interface.dart';
import 'package:screen_capture_detector/screen_capture_detector_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenCaptureDetectorPlatform
    with MockPlatformInterfaceMixin
    implements ScreenCaptureDetectorPlatform {

  
}

void main() {
  final ScreenCaptureDetectorPlatform initialPlatform = ScreenCaptureDetectorPlatform.instance;

  test('$MethodChannelScreenCaptureDetector is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenCaptureDetector>());
  });

}
