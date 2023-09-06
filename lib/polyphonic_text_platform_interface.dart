import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'polyphonic_text_method_channel.dart';

abstract class PolyphonicTextPlatform extends PlatformInterface {
  /// Constructs a PolyphonicTextPlatform.
  PolyphonicTextPlatform() : super(token: _token);

  static final Object _token = Object();

  static PolyphonicTextPlatform _instance = MethodChannelPolyphonicText();

  /// The default instance of [PolyphonicTextPlatform] to use.
  ///
  /// Defaults to [MethodChannelPolyphonicText].
  static PolyphonicTextPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PolyphonicTextPlatform] when
  /// they register themselves.
  static set instance(PolyphonicTextPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> downloadFontIfNeed({
    required String fontUrl,
  }) {
    throw UnimplementedError('downloadFontIfNeed() has not been implemented.');
  }

  Future<bool> isFontInstalled({
    String? fontName,
  }) {
    throw UnimplementedError('downloadFontIfNeed() has not been implemented.');
  }
}
