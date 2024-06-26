import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polyphonic_text/polyphonic_text.dart';
import 'package:polyphonic_text/polyphonic_text_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDownloadingFont = true;

  bool _showPy = false;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    await PolyphonicTextPlatform.instance
        .downloadFontIfNeed(fontUrl: 'https://www.tigeridea.cn/zuidongfeng/font/ATTPY.ttf', fontName: "ATTPY");
    setState(() {
      _isDownloadingFont = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(
                onPressed: () {
                  _showPy = !_showPy;
                  if (mounted) {
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.read_more))
          ],
        ),
        body: _isDownloadingFont
            ? const CupertinoActivityIndicator(color: Colors.red, radius: 30)
            : Stack(
                children: [
                  const ColoredBox(color: Colors.red, child: SizedBox.expand()),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: ColoredBox(color: Colors.green.withOpacity(0.6), child: const SizedBox.expand()),
                  ),
                  Column(
                    children: [
                      ColoredBox(
                        color: Colors.teal,
                        child: Visibility(
                          visible: _showPy,
                          replacement: Text(
                            '朝\udb40\udde1如青丝暮成雪。' * 2,
                            style: const TextStyle(fontSize: 30),
                          ),
                          child: PolyphonicTextView(
                            text: '朝\udb40\udde1如青丝暮成雪。' * 2,
                            color: Colors.white,
                            fontSize: 30,
                            height: 34 / 30,
                            fontFamily: "ATTPY",
                          ),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.red,
                        child: Visibility(
                          visible: _showPy,
                          replacement: Text(
                            '朝\udb40\udde1如青丝暮成雪。' * 4,
                            style: const TextStyle(fontSize: 30),
                          ),
                          child: PolyphonicTextView(
                            text: '朝\udb40\udde1如青丝暮成雪。' * 4,
                            color: Colors.white,
                            fontSize: 38,
                            height: 42 / 38,
                            fontFamily: "ATTPY",
                          ),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.green,
                        child: Visibility(
                          visible: _showPy,
                          replacement: Text(
                            '朝\udb40\udde1如青丝暮成雪。' * 2,
                            style: const TextStyle(fontSize: 30),
                          ),
                          child: PolyphonicTextView(
                            text: '朝\udb40\udde1如青丝暮成雪。' * 2,
                            color: Colors.white,
                            fontFamily: "ATTPY",
                            fontSize: 30,
                            height: 34 / 30,
                          ),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.cyanAccent,
                        child: Visibility(
                          visible: _showPy,
                          replacement: Text(
                            '朝\udb40\udde1如青丝暮成雪。' * 2,
                            style: const TextStyle(fontSize: 30),
                          ),
                          child: PolyphonicTextView(
                            text: '朝\udb40\udde1如青丝暮成雪。' * 2,
                            color: Colors.white,
                            fontFamily: "ATTPY",
                            fontSize: 22,
                            height: 26 / 22,
                          ),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.purple,
                        child: Visibility(
                          visible: _showPy,
                          replacement: Text(
                            '朝\udb40\udde1如青丝暮成雪。' * 2,
                            style: const TextStyle(fontSize: 30),
                          ),
                          child: PolyphonicTextView(
                            text: '朝\udb40\udde1如青丝暮成雪。' * 2,
                            fontFamily: "ATTPY",
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.yellow,
                        child: Visibility(
                          visible: _showPy,
                          replacement: Text(
                            '朝\udb40\udde1如青丝暮成雪。' * 2,
                            style: const TextStyle(fontSize: 30),
                          ),
                          child: PolyphonicTextView(
                            text: '朝\udb40\udde1如青丝暮成雪。' * 2,
                            fontFamily: "ATTPY",
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ],
                  )
                  // ListView.builder(
                  //   itemBuilder: (context, index) {
                  //     return ColoredBox(
                  //       color: Colors.primaries[index % Colors.primaries.length],
                  //       child: Visibility(
                  //         visible: _showPy,
                  //         replacement: Text('朝\udb40\udde1如青丝暮成雪。' * (Random().nextInt(20) + 1)),
                  //         child: PolyphonicTextView(
                  //           text: '朝\udb40\udde1如青丝暮成雪。' * (Random().nextInt(20) + 1),
                  //           color: Colors.white,
                  //           fontSize: 30,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   itemCount: 1000,
                  // ),
                ],
              ),
      ),
    );
  }
}
