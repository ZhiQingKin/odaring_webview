import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odaring_web_view/odaring_web_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool finishedLoading = false;
  String web = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              BaseWebView(
                webUrl: "https://flutter.dev/",
                title: 'webview.title.payment',
                onJavascriptChannelReceived: (value) {
                  if (kDebugMode) {
                    print(value);
                  }
                },
                javascriptChannelName: "payment",
                onScroll: (y) {
                  if (kDebugMode) {
                    print("data : Y ${y} ");
                  }
                },
              ),
              isLoading
                  ? Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.center,
                        child: BaseLottieFilesDisplay(
                          lottieType: LottieType.Assets,
                          containerHeight: 200,
                          containerWidth: double.infinity,
                          file: 'images/widgets/Loading animation.json',
                          height: 60,
                          width: double.infinity,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
