import 'dart:async';
import 'package:flutter/material.dart';
import 'package:odaring_web_view/src/base_webview/webview_main_scroll.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BaseWebView extends StatelessWidget {

  String? webUrl;
  String? title;
  bool gestureNavigation;
  Completer<WebViewController>? controller;
  Function(String)? onJavascriptChannelReceived;
  NavigationDecision Function(NavigationRequest request)? navigateDelegate;
  String? javascriptChannelName;
  Function(String)? onPageStart;
  Function(String)? onPageEnded;
  Function(int)? onProgress;
  ValueChanged<double>? onScroll;

  BaseWebView({
    this.webUrl,
    this.title,
    this.gestureNavigation = false,
    this.controller,
    this.onJavascriptChannelReceived,
    this.javascriptChannelName,
    this.navigateDelegate,
    this.onPageEnded,
    this.onPageStart,
    this.onProgress,
    this.onScroll
  });

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: javascriptChannelName != null ? javascriptChannelName! : "default",
        onMessageReceived: (JavascriptMessage message) {
          if(onJavascriptChannelReceived != null){
            onJavascriptChannelReceived!(message.message);
          }
        });
  }

  Widget build(BuildContext context){
    if(onScroll != null){
      return WebViewScrollControl(
        onScroll: onScroll,
        webUrl: webUrl,
        title: title,
        gestureNavigation: gestureNavigation,
        javascriptChannelName: javascriptChannelName,
        controller: controller,
        onJavascriptChannelReceived: onJavascriptChannelReceived,
        onPageStart: onPageStart,
        onPageEnded: onPageEnded,
        navigateDelegate: navigateDelegate,
        onProgress: (int progress) {},
      );
    }else{
      return WebView(
        initialUrl: webUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          if(controller != null){
            controller!.complete(webViewController);
          }
        },
        onProgress: onProgress,
        navigationDelegate: navigateDelegate,
        javascriptChannels: <JavascriptChannel>{
          _toasterJavascriptChannel(context),
        },
        gestureNavigationEnabled: gestureNavigation,
        onPageFinished: onPageEnded,
        onPageStarted: onPageStart,
      );
    }
  }
}