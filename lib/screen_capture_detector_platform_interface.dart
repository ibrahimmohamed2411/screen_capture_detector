import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'screen_capture_detector_method_channel.dart';

abstract class ScreenCaptureDetectorPlatform extends PlatformInterface {
  /// Constructs a ScreenCaptureDetectorPlatform.
  ScreenCaptureDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenCaptureDetectorPlatform _instance = MethodChannelScreenCaptureDetector();

  /// The default instance of [ScreenCaptureDetectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenCaptureDetector].
  static ScreenCaptureDetectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenCaptureDetectorPlatform] when
  /// they register themselves.
  static set instance(ScreenCaptureDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

}
