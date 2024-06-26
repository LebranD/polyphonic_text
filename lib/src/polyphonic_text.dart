import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../polyphonic_text.dart';

class PolyphonicTextView extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final double fontSize;
  final Color? color;
  final double? height;
  final String? fontFamily;
  final FontWeight fontWeight;
  const PolyphonicTextView(
      {super.key,
      required this.text,
      this.textAlign = TextAlign.start,
      this.maxLines,
      this.overflow = TextOverflow.ellipsis,
      this.fontSize = 14,
      required this.color,
      this.height,
      this.fontFamily,
      this.fontWeight = FontWeight.w500});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return _PolyphonicTextView(
        text: text,
        maxLines: maxLines,
        overflow: overflow,
        fontSize: fontSize,
        fontFamily: fontFamily,
        textAlign: textAlign,
        color: color,
        fontWeight: fontWeight,
        height: height,
        maxWidth: constraints.maxWidth,
      );
    });
  }
}

class _PolyphonicTextView extends StatefulWidget {
  const _PolyphonicTextView({
    super.key,
    required this.text,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.fontSize = 14,
    this.textAlign = TextAlign.start,
    Color? color,
    this.height,
    this.fontWeight = FontWeight.w500,
    this.fontFamily = MethodChannelPolyphonicText.kDefaultFontName,
    required this.maxWidth,
  }) : textColor = color ?? const Color(0xFF313131);

  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final double fontSize;
  final Color textColor;
  final double? height;
  final String? fontFamily;
  final FontWeight fontWeight;
  final double maxWidth;

  @override
  State<_PolyphonicTextView> createState() => _PolyphonicTextViewState();
}

class _PolyphonicTextViewState extends State<_PolyphonicTextView> {
  final ValueNotifier<double> _heightNotifier = ValueNotifier(0);

  UniqueKey _key = UniqueKey();

  MethodChannel? _channel;

  late Map<String, dynamic> _creationParams;

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('polyphonic_text_factory_$id')
      ..setMethodCallHandler((call) async {
        if (call.method == 'afterLayout') {
          _heightNotifier.value = call.arguments['height'];
        }
      });
  }

  @override
  void initState() {
    super.initState();
    _heightNotifier.value = _calculateDefaultSize(widget.maxWidth);
    _creationParams = <String, dynamic>{
      'text': widget.text,
      'maxLines': widget.maxLines,
      'overflow': widget.overflow.index,
      'fontFamily': widget.fontFamily,
      'fontSize': widget.fontSize,
      'textAlign': widget.textAlign.index,
      'fontWeight': widget.fontWeight.value,
      'textColor': {
        'r': widget.textColor.red,
        'g': widget.textColor.green,
        'b': widget.textColor.blue,
        'a': widget.textColor.alpha,
      },
      'height': widget.height,
    };
  }

  double _calculateDefaultSize(double maxWidth) {
    final textStyle = TextStyle(
        fontSize: widget.fontSize, height: widget.height, fontFamily: widget.fontFamily, fontWeight: widget.fontWeight);
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: textStyle),
      textDirection: TextDirection.ltr,
        maxLines: widget.maxLines
    );
    textPainter.layout(maxWidth: maxWidth);
    final textSize = textPainter.size;
    return textSize.height;
  }

  @override
  void dispose() {
    _heightNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PolyphonicTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _creationParams = {
        'text': widget.text,
        'maxLines': widget.maxLines,
        'overflow': widget.overflow.index,
        'fontSize': widget.fontSize,
        'textAlign': widget.textAlign.index,
        'fontFamily': widget.fontFamily,
        'fontWeight': widget.fontWeight.value,
        'textColor': {
          'r': widget.textColor.red,
          'g': widget.textColor.green,
          'b': widget.textColor.blue,
          'a': widget.textColor.alpha,
        },
        'height': widget.height,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget nativeView = defaultTargetPlatform == TargetPlatform.android
        ? AndroidView(
            key: _key,
            viewType: 'polyphonic_text_factory',
            creationParams: _creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          )
        : UiKitView(
            key: _key,
            viewType: 'polyphonic_text_factory',
            creationParams: _creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          );
    return ValueListenableBuilder<double>(
        valueListenable: _heightNotifier,
        builder: (context, value, child) {
          return SizedBox(
            height: value,
            child: nativeView,
          );
        },
        child: nativeView);
  }
}
