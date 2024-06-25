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
                result(false);
                return
            }
            if (isFontRegistered(fontName)) {
                result(true)
                return;
            }
            guard let url = URL(string: urlStr) else {
             result(false)
             return
            }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first;
            var path: String;
            if #available(iOS 16.0, *) {
                path = documentsDirectory!.path() + "\(fontName).ttf"
            } else {
                path = documentsDirectory!.path + "\(fontName).ttf"
            };
            let isFileExists = FileManager.default.fileExists(atPath: path)
            if (isFileExists) {
                let fontData = NSData.init(contentsOfFile: path)!
                let fontBytes = fontData.bytes.assumingMemoryBound(to: UInt8.self)
                guard let fontDataPtr = CFDataCreate(kCFAllocatorDefault, fontBytes, fontData.length),
                      let provider = CGDataProvider.init(data: fontDataPtr),
                      let font = CGFont.init(provider) else {
                    result(false)
                    return
                }
                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(font, &error) {
                    result(false);
                }
                else {
                    result(true);
                }
                return;
            }
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, resp, error) in
                if (error != nil) {
                    result(FlutterError(code: "-4", message: "download font failed", details: error?.localizedDescription));
                } else {
                    guard let data = data as? NSData else {
                     result(false)
                     return
                    }
                    do {
                        try data.write(toFile: path)
                    } catch {
                        print("写入文件失败：\(error.localizedDescription)")
                    }
                    let fontBytes = data.bytes.assumingMemoryBound(to: UInt8.self)
                    guard let fontDataPtr = CFDataCreate(kCFAllocatorDefault, fontBytes, data.length),
                          let provider = CGDataProvider.init(data: fontDataPtr),
                          let font = CGFont.init(provider) else {
                          result(false)
                        return
                    }
                    var error: Unmanaged<CFError>?
                    if !CTFontManagerRegisterGraphicsFont(font, &error) {
                        result(false)
                    } else {
                       result(true)
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
