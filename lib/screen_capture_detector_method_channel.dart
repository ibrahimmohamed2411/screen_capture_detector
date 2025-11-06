import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screen_capture_detector_platform_interface.dart';

/// An implementation of [ScreenCaptureDetectorPlatform] that uses method channels.
class MethodChannelScreenCaptureDetector extends ScreenCaptureDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screen_capture_detector');
}
