//
//  PolyphonicText.swift
//  polyphonic_text
//
//  Created by 邓先舜 on 2023/9/5.
//

import Flutter
import Foundation

class PolyphonicText: NSObject, FlutterPlatformView {
    private var _view: _PolyphonicTextView?;
    private var _channel: FlutterMethodChannel;
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(name: "polyphonic_text_factory_\(viewId)", binaryMessenger: messenger);
        _view = _PolyphonicTextView(frame: frame, arguments: args, _channel)
        super.init()
    }
    
    func view() -> UIView {
        return _view!
    }
}

class _PolyphonicTextView: UIView {
    
    private var label: UILabel;
    public var afterLayout: ((CGSize) -> Void)?;
    private var _channel: FlutterMethodChannel?;

    private var text: String = "";
    private var textColor: UIColor = .orange;
    private var textAlignment: NSTextAlignment = .left;
    private var numberOfLines: Int = 0;
    private var lineBreakMode: NSLineBreakMode = .byClipping;
    private var fontSize: CGFloat = 14.0;
    private var lineSpace: CGFloat = 14.0;
    private var fontName: String = "ToneOZ-Pinyin-WenKai-Regular";
    
    init(
        frame: CGRect,
        arguments args: Any?,
        _ channel: FlutterMethodChannel
    ) {
        label = UILabel()
        _channel = channel
        super.init(frame: frame)
        dump(args: args)
        createLabel(args: args)
    }
    
    required init?(coder: NSCoder) {
        label = UILabel()
        super.init(coder: coder)
    }
    
    private func dump(args: Any?) {
        guard let args = args as? [String: Any] else { return }
        self.text = (args["text"] as? String) ?? ""
        self.fontSize = CGFloat((args["fontSize"] as? NSNumber)?.floatValue ?? 14.0);
        
        self.textColor = colorFromArgs(args: args["textColor"] as? [String: Any]) ?? UIColor.black
        self.textAlignment = textAlignFromArgs((args["textAlign"] as? NSNumber)?.intValue ?? 0)
        self.numberOfLines = (args["maxLines"] as? NSNumber)?.intValue ?? 0;
        self.lineBreakMode = lineBreakModeFromArgs((args["overflow"] as? NSNumber)?.intValue ?? 0);
        let lineSpace = CGFloat((args["height"] as? NSNumber)?.floatValue ?? 1.0);
        self.lineSpace = lineSpace > 1 ? self.fontSize * (lineSpace - 1) : 0;
    }
    
    private func colorFromArgs(args: [String: Any]?) -> UIColor? {
        guard let r = args?["r"] as? NSNumber,
              let g = args?["g"] as? NSNumber,
              let b = args?["b"] as? NSNumber,
              let a = args?["a"] as? NSNumber  else { return nil }
        let color = UIColor.init(red: CGFloat(truncating: r) / 255.0, green: CGFloat(truncating: g) / 255.0, blue: CGFloat(truncating: b) / 255.0, alpha: CGFloat(truncating: a) / 255.0)
        return color
    }
    
    private func lineBreakModeFromArgs(_ textOverFlow: Int) -> NSLineBreakMode {
        switch textOverFlow {
        case 2:
            return NSLineBreakMode.byTruncatingTail;
        default:
            return NSLineBreakMode.byClipping;
        }
    }
    
    private func textAlignFromArgs(_ textAlign: Int) -> NSTextAlignment {
        switch textAlign {
        case 0:
            return NSTextAlignment.left;
        case 1:
            return NSTextAlignment.right;
        case 2:
            return NSTextAlignment.center;
        case 3:
            return NSTextAlignment.justified;
        case 4:
            return NSTextAlignment.left;
        case 5:
            return NSTextAlignment.right;
        default:
            return NSTextAlignment.left;
        }
    }
    
    private func createLabel(args: Any?) -> Void {
        label.text = self.text
        label.textColor = self.textColor
        label.textAlignment = self.textAlignment
        label.numberOfLines = self.numberOfLines
        label.lineBreakMode = self.lineBreakMode
        label.font = UIFont(name: "ToneOZ-Pinyin-WenKai-Regular", size: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = self.lineSpace;
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        let mutableStr = NSMutableAttributedString(string: self.text)
        mutableStr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableStr.length))
        mutableStr.addAttribute(.foregroundColor, value:self.textColor, range: NSRange(location: 0, length: mutableStr.length))
        mutableStr.addAttribute(.font, value: UIFont(name: self.fontName, size: self.fontSize) as Any, range: NSRange(location: 0, length: mutableStr.length))
        label.attributedText = mutableStr
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: self.leftAnchor),
            label.rightAnchor.constraint(equalTo: self.rightAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let suitSize = label.sizeThatFits(CGSize.init(width: self.frame.width, height: self.frame.height))
        _channel?.invokeMethod("afterLayout", arguments: ["width": suitSize.width, "height": suitSize.height])
    }
}




