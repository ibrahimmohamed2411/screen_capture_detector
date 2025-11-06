import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class ScreenCaptureDetector {
  static const MethodChannel _channel = MethodChannel('screen_capture_detector');

  final StreamController<String?> _screenshotController = StreamController<String?>.broadcast();

  Stream<String?> get screenshotStream => _screenshotController.stream;

  bool _isListening = false;

  ScreenCaptureDetector() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  /// Requests permissions if needed (Android only).
  ///
  /// - On Android 13+ → requests [Permission.photos].
  /// - On older Android versions → requests [Permission.storage].
  /// - On iOS → always returns `true` (no permissions required).
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      PermissionStatus status;

      if (await _isAndroid13OrAbove()) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      return status.isGranted || status.isLimited;
    }
    return true;
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final int sdkInt = await _channel.invokeMethod('getSdkVersion');
      return sdkInt >= 33;
    } catch (e) {
      return false;
    }
  }

  /// Starts listening for screenshots on the current platform.
  ///
  /// Returns `true` if detection started successfully.

  Future<bool> startListening() async {
    if (_isListening) return true;

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      developer.log('Cannot start detection: permissions not granted');
      return false;
    }

    try {
      final bool result = await _channel.invokeMethod('startDetection');
      _isListening = result;
      return result;
    } catch (e) {
      developer.log('Error starting screenshot detection: $e');
      return false;
    }
  }

  /// Stops listening for screenshots.

  Future<bool> stopListening() async {
    if (!_isListening) return true;

    try {
      final bool result = await _channel.invokeMethod('stopDetection');
      _isListening = false;
      return result;
    } catch (e) {
      developer.log('Error stopping screenshot detection: $e');
      return false;
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'onScreenshotTaken') {
      final String? path = call.arguments as String?;
      _screenshotController.add(path);
      developer.log('Screenshot detected:${path != null ? ': $path' : ''}');
    }
  }

  /// Disposes the detector and releases resources.

  void dispose() {
    stopListening();
    _screenshotController.close();
  }
}
