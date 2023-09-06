import Flutter
import UIKit
import CoreText

public class PolyphonicTextPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "polyphonic_text", binaryMessenger: registrar.messenger())
        let instance = PolyphonicTextPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let factory = PolyphonicTextFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "polyphonic_text_factory")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "downloadFontIfNeed":
            guard
                let args = call.arguments as? [String: Any],
                let urlStr = args["fontUrl"] as? String,
                let fontName = args["fontName"] as? String else {
                result(FlutterError(code: "-1", message: "fontUrl must not be null", details: nil));
                return
            }
            if (isFontRegistered(fontName)) {
                result(nil)
                return;
            }
            guard let url = URL(string: urlStr) else { return }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first;
            var path: String;
            if #available(iOS 16.0, *) {
                path = documentsDirectory!.path() + url.lastPathComponent
            } else {
                path = documentsDirectory!.path + url.lastPathComponent
            };
            let isFileExists = FileManager.default.fileExists(atPath: path)
            if (isFileExists) {
                let fontData = NSData.init(contentsOfFile: path)!
                let fontBytes = fontData.bytes.assumingMemoryBound(to: UInt8.self)
                guard let fontDataPtr = CFDataCreate(kCFAllocatorDefault, fontBytes, fontData.length),
                      let provider = CGDataProvider.init(data: fontDataPtr),
                      let font = CGFont.init(provider) else {
                    result(FlutterError(code: "-2", message: "dump font failed", details: nil));
                    return
                }
                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(font, &error) {
                    result(FlutterError(code: "-3", message: "register font failed", details: nil));
                }
                else {
                    print("Register Success")
                    result(nil);
                }
                return;
            }
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, resp, error) in
                if (error != nil) {
                    result(FlutterError(code: "-4", message: "download font failed", details: error?.localizedDescription));
                } else {
                    guard let data = data as? NSData else { return }
                    do {
                        try data.write(toFile: path)
                    } catch {
                        print("写入文件失败：\(error.localizedDescription)")
                    }
                    let fontBytes = data.bytes.assumingMemoryBound(to: UInt8.self)
                    guard let fontDataPtr = CFDataCreate(kCFAllocatorDefault, fontBytes, data.length),
                          let provider = CGDataProvider.init(data: fontDataPtr),
                          let font = CGFont.init(provider) else {
                        result(FlutterError(code: "-2", message: "dump font failed", details: nil));
                        return
                    }
                    var error: Unmanaged<CFError>?
                    if !CTFontManagerRegisterGraphicsFont(font, &error) {
                        let errorDescription = CFErrorCopyDescription((error as! CFError))
                        result(FlutterError(code: "-3", message: "register font failed", details: errorDescription));
                    }
                    else {
                        print("Register Success")
                        result(nil);
                    }
                }
            }
            task.resume();
        case "isFontInstalled":
            guard
                let args = call.arguments as? [String: Any],
                let fontName = args["fontName"] as? String else {
                result(false);
                return
            }
            result(isFontRegistered(fontName))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    func isFontRegistered(_ fontName: String) -> Bool {
        if UIFont(name: fontName, size: 12) != nil {
            return true
        } else {
            return false
        }
    }

}
