# polyphonic_text

由于 Flutter 不支持多音字字体，使用原生AndroidView/UIKitView替代展示拼音字体

[issue](https://github.com/flutter/flutter/issues/134020)

## Getting Started

⚠️ ⚠️ ⚠️ 目前已知PolyphonicTextView不可包裹在ListView等滑动控件中 ⚠️ ⚠️ ⚠️ 

⚠️ ⚠️ ⚠️ 集成AndroidView/UIKitView平台视图的时候需要注意原生视图高度问题 ⚠️ ⚠️ ⚠️    

```dart
    //

    // 检查字体是否安装
    bool isInstalled = await PolyphonicTextPlatform.instance.isFontInstalled();

    // 下载并注册字体
    await PolyphonicTextPlatform.instance.downloadFontIfNeed(fontUrl: 'https://www.tigeridea.cn/zuidongfeng/font/ATTPY.ttf');

    /// 使用
    PolyphonicTextView(
        text: '朝\udb40\udde1如青丝暮成雪。',
        fontSize: 22,
        height: 1.1,
        maxLines: 0,
    )

```

