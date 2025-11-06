import Flutter
import UIKit

public class ScreenCaptureDetectorPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "screen_capture_detector", binaryMessenger: registrar.messenger())
    let instance = ScreenCaptureDetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     switch call.method {
        case "startDetection":
            startScreenshotDetection()
            result(true)
        case "stopDetection":
            stopScreenshotDetection()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
  }

  private func startScreenshotDetection() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onScreenshotDetected),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

  private func stopScreenshotDetection() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

  @objc private func onScreenshotDetected() {
        channel?.invokeMethod("onScreenshotTaken", arguments: nil)
    }

  deinit {
        stopScreenshotDetection()
    }

}
