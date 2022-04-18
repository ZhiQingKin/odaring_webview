import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:odaring_web_view/src/base_webview/webview_container.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_child.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_coordinator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class WebViewScrollControl extends StatefulWidget {
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
  ValueChanged<double>? onScroll;

  WebViewScrollControl(
      {Key? key,
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
      this.onScroll})
      : super(key: key);

  @override
  _WebViewScrollControlState createState() => _WebViewScrollControlState();
}

class _WebViewScrollControlState extends State<WebViewScrollControl> {
  late NestedInnerScrollCoordinator _coordinator;

  final Key _webviewKey = const ValueKey("webview");

  @override
  void initState() {
    super.initState();
    _coordinator = NestedInnerScrollCoordinator(ScrollController());
    _coordinator.outerController.addListener(() {
      if(widget.onScroll != null){
        widget.onScroll!(_coordinator.outerController.offset);
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _coordinator.outerController,
      scrollBehavior: MyCustomScrollBehavior(),
      slivers: [
        SliverToBoxAdapter(
          child: NestedInnerScrollChild(
            scrollKey: _webviewKey,
            child: Scrollable(
              controller: _coordinator.innerController,
              viewportBuilder: (context, offset) {
                return WebViewContainer(
                  offset: offset,
                  webUrl: widget.webUrl,
                  title: widget.title,
                  controller: widget.controller,
                  gestureNavigation: widget.gestureNavigation,
                  onJavascriptChannelReceived: widget.onJavascriptChannelReceived,
                  onPageEnded: widget.onPageEnded,
                  onPageStart: widget.onPageStart,
                  javascriptChannelName: widget.javascriptChannelName,
                  navigateDelegate: widget.navigateDelegate,
                  onProgress: widget.onProgress,
                );
              },
            ),
            coordinator: _coordinator,
          ),
        ),
      ],
    );
  }
}
