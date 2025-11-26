import Flutter
import UIKit

public class OpenInstallPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.openinstall.flutter/screen",
            binaryMessenger: registrar.messenger()
        )
        let instance = OpenInstallPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getScreenInfo":
            let screenInfo = getScreenInfo()
            result(screenInfo)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getScreenInfo() -> [String: Any] {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale

        return [
            "width": Int(bounds.width * scale),
            "height": Int(bounds.height * scale),
            "colorDepth": 24,
            "pixelRatio": scale,
            "scale": scale,
            "density": scale
        ]
    }
}



