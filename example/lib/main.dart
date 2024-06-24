import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    final downloadRes = await PolyphonicTextPlatform.instance.downloadFontIfNeed(fontUrl: 'https://www.tigeridea.cn/zuidongfeng/font/ATTPY.ttf');
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
        ),
        body: _isDownloadingFont
            ? const CupertinoActivityIndicator(color: Colors.red, radius: 30)
            :
            // Padding(
            //     padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
            //     child: PolyphonicTextView(
            //       text: '朝\udb40\udde1如青丝暮成雪。朝\udb40\udde1如青丝暮成雪。',
            //       color: Colors.orange,
            //       overflow: TextOverflow.ellipsis,
            //       maxLines: 0,
            //       fontSize: 30,
            //     ),
            //   ),

            ListView.builder(
                itemBuilder: (context, index) {
                  return ColoredBox(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: PolyphonicTextView(
                      text: '朝\udb40\udde1如青丝暮成雪。' * (Random().nextInt(20) + 1),
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  );
                },
                itemCount: 1000,
              ),

        // ColoredBox(
        //     color: Colors.green,
        //     child: ListView(
        //       shrinkWrap: true,
        //       physics: NeverScrollableScrollPhysics(),
        //       padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
        //       children: [
        //         ColoredBox(
        //           color: Colors.red,
        //           child: PolyphonicTextView(
        //             text: '朝\udb40\udde1如青丝暮成雪。朝\udb40\udde1如青丝暮成雪。',
        //             color: Colors.orange,
        //             overflow: TextOverflow.ellipsis,
        //             maxLines: 0,
        //             fontSize: 30,
        //           ),
        //         ),
        //         ColoredBox(
        //           color: Colors.red,
        //           child: PolyphonicTextView(
        //             text: '朝\udb40\udde1如青丝暮成雪。',
        //             color: Colors.orange,
        //             fontSize: 30,
        //           ),
        //         ),
        //         ColoredBox(
        //           color: Colors.red,
        //           child: PolyphonicTextView(
        //             text: '朝\udb40\udde1如青丝暮成雪。',
        //             color: Colors.orange,
        //             fontSize: 30,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ),
    );
  }
}
