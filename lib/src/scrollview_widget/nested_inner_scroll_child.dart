import 'package:flutter/cupertino.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_coordinator.dart';

class NestedInnerScrollChild extends StatefulWidget {
  final Widget child;

  final NestedInnerScrollCoordinator coordinator;

  final Key scrollKey;

  const NestedInnerScrollChild(
      {Key? key,
        required this.scrollKey,
        required this.coordinator,
        required this.child})
      : super(key: key);
  @override
  _NestedInnerScrollChildState createState() => _NestedInnerScrollChildState();
}

class _NestedInnerScrollChildState extends State<NestedInnerScrollChild> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      child: NotificationListener<ScrollEndNotification>(
        child: widget.child,
        onNotification: (end) {
          widget.coordinator.innerTouchingKey = null;
          return false;
        },
      ),
      onPointerDown: _startScrollInner,
    );
  }

  void _startScrollInner(_) {
    widget.coordinator.innerTouchingKey = widget.scrollKey;
  }
}