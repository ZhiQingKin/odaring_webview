import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:odaring_web_view/src/custom_viewport/web_viewport.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  final ViewportOffset offset;
  String? webUrl;
  String? title;
  bool? gestureNavigation;
  Completer<WebViewController>? controller;
  Function(String)? onJavascriptChannelReceived;
  NavigationDecision Function(NavigationRequest request)? navigateDelegate;
  String? javascriptChannelName;
  Function(String)? onPageStart;
  Function(String)? onPageEnded;
  Function(int)? onProgress;

  WebViewContainer(
      {Key? key,
      required this.offset,
      this.webUrl,
      this.title,
      this.gestureNavigation = false,
      this.controller,
      this.onJavascriptChannelReceived,
      this.javascriptChannelName,
      this.navigateDelegate,
      this.onPageEnded,
      this.onPageStart,
      this.onProgress,})
      : super(key: key);

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  double _contentHeight = 0;
  WebViewController? _webController;

  @override
  Widget build(BuildContext context) {
    if (_contentHeight == 0) {
      return SizedBox(
        height: 1,
        child: WebView(
          initialUrl: widget.webUrl,
          onWebViewCreated: (WebViewController webViewController) {
            if(widget.controller != null){
              widget.controller!.complete(webViewController);
            }
            _webController = webViewController;
          },
          javascriptMode: JavascriptMode.unrestricted,
          debuggingEnabled: true,
          onPageFinished: (some) async {
            if (_webController != null) {
              _contentHeight = double.tryParse(
                await _webController!.runJavascriptReturningResult(
                    "document.documentElement.scrollHeight;"),
              ) ??
                  100;
              setState(() {});
            }
          },
        ),
      );
    }
    return WebViewPort(
      offset: widget.offset,
      clipBehavior: Clip.hardEdge,
      onScroll: (Offset offset){
        _webController
            ?.runJavascriptReturningResult("window.scrollTo(0,${offset.dy.abs().ceil()})");
      },
      child: SizedBox(
        height: _contentHeight,
        child: WebView(
          initialUrl: widget.webUrl,
          onWebViewCreated: (WebViewController webViewController) {
            if(widget.controller != null){
              widget.controller!.complete(webViewController);
            }
            _webController = webViewController;
          },
          javascriptMode: JavascriptMode.unrestricted,
          debuggingEnabled: true,
        ),
      ),
      contentHeight: _contentHeight,
    );
  }
}
