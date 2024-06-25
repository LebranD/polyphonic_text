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
  Future<bool> downloadFontIfNeed({required String fontUrl, String? fontName}) async {
    final res = await methodChannel.invokeMethod<bool>('downloadFontIfNeed', {
      'fontUrl': fontUrl,
      'fontName': fontName ?? kDefaultFontName,
    });
    return res ?? false;
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
