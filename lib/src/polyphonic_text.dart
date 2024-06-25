import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../polyphonic_text.dart';

class PolyphonicTextView extends StatefulWidget {
  const PolyphonicTextView({
    super.key,
    required this.text,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.fontSize = 14,
    this.textAlign = TextAlign.start,
    Color? color,
    this.height,
    this.fontFamily = MethodChannelPolyphonicText.kDefaultFontName,
  }) : textColor = color ?? const Color(0xFF313131);

  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final double fontSize;
  final Color textColor;
  final double? height;
  final String? fontFamily;

  @override
  State<PolyphonicTextView> createState() => _PolyphonicTextViewState();
}

class _PolyphonicTextViewState extends State<PolyphonicTextView> {
  final ValueNotifier<double?> _heightNotifier = ValueNotifier(null);
  final UniqueKey _key = UniqueKey();

  // ignore: unused_field
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
    _creationParams = <String, dynamic>{
      'text': widget.text,
      'maxLines': widget.maxLines,
      'overflow': widget.overflow.index,
      'fontFamily': widget.fontFamily,
      'fontSize': widget.fontSize,
      'textAlign': widget.textAlign.index,
      'textColor': {
        'r': widget.textColor.red,
        'g': widget.textColor.green,
        'b': widget.textColor.blue,
        'a': widget.textColor.alpha,
      },
      'height': widget.height,
    };
  }

  double _caculateDefaultSize(double maxWidth) {
    final textStyle = TextStyle(fontSize: widget.fontSize, height: widget.height);
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    final textSize = textPainter.size;
    return textSize.height;
  }

  @override
  void didUpdateWidget(covariant PolyphonicTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _creationParams = {
        'text': widget.text,
        'maxLines': widget.maxLines,
        'overflow': widget.overflow.index,
        'fontSize': widget.fontSize,
        'textAlign': widget.textAlign.index,
        'fontFamily': widget.fontFamily,
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      return ValueListenableBuilder(
        valueListenable: _heightNotifier,
        builder: (context, value, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: value ?? _caculateDefaultSize(constraints.maxWidth),
                width: constraints.maxWidth,
                child: AndroidView(
                  key: _key,
                  viewType: 'polyphonic_text_factory',
                  creationParams: _creationParams,
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: _onPlatformViewCreated,
                ),
              );
            },
          );
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ValueListenableBuilder(
        valueListenable: _heightNotifier,
        builder: (context, value, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: value ?? _caculateDefaultSize(constraints.maxWidth),
                width: double.infinity,
                child: UiKitView(
                  key: _key,
                  viewType: 'polyphonic_text_factory',
                  creationParams: _creationParams,
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: _onPlatformViewCreated,
                ),
              );
            },
          );
        },
      );
    }
    return Container();
  }
}
