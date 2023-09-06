import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'polyphonic_text_platform_interface.dart';

/// An implementation of [PolyphonicTextPlatform] that uses method channels.
class MethodChannelPolyphonicText extends PolyphonicTextPlatform {
  static const String kDefaultFontName = 'ToneOZ-Pinyin-WenKai-Regular';

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('polyphonic_text');

  @override
  Future<void> downloadFontIfNeed({
    required String fontUrl,
    String fontName = 'ToneOZ-Pinyin-WenKai-Regular',
  }) async {
    await methodChannel.invokeMethod<void>('downloadFontIfNeed', {
      'fontUrl': fontUrl,
      'fontName': fontName,
    });
  }

  @override
  Future<bool> isFontInstalled({
    String? fontName,
  }) async {
    return await methodChannel.invokeMethod<bool>('isFontInstalled', {
          'fontName': fontName ?? kDefaultFontName,
        }) ??
        false;
  }
}
