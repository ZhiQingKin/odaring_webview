import 'package:flutter/cupertino.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_coordinator.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_scroll_position.dart';

class NestedInnerScrollController extends ScrollController {
  NestedInnerScrollController(
      this.coordinator, {
        double initialScrollOffset = 0.0,
        String debugLabel = "unknown",
      }) : super(initialScrollOffset: initialScrollOffset, debugLabel: debugLabel);

  final NestedInnerScrollCoordinator coordinator;

  @override
  ScrollPosition createScrollPosition(
      ScrollPhysics physics,
      ScrollContext context,
      ScrollPosition? oldPosition,
      ) {
    return NestedScrollPosition(
      coordinator: coordinator,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel!,
    );
  }

  //disable Notification pop up
  void justForcePixels(double value) {
    assert(nestedPositions.isNotEmpty);
    for (NestedScrollPosition position in nestedPositions) {
      position.justForcePixels(value);
    }
  }

  @override
  void attach(ScrollPosition position) {
    assert(position is NestedScrollPosition);
    super.attach(position);
    NestedScrollPosition _nestedScrollPosition =
    position as NestedScrollPosition;
    coordinator.attachInnerScrollPosition(_nestedScrollPosition);
    coordinator.updateParent();
    coordinator.updateCanDrag(_nestedScrollPosition);
    position.addListener(_scheduleUpdateShadow);
    _scheduleUpdateShadow();
  }

  @override
  void detach(ScrollPosition position) {
    assert(position is NestedScrollPosition);
    coordinator.detachInnerScrollPosition(position as NestedScrollPosition);
    position.removeListener(_scheduleUpdateShadow);
    super.detach(position);
    _scheduleUpdateShadow();
  }

  void _scheduleUpdateShadow() {
    // We do this asynchronously for attach() so that the new position has had
    // time to be initialized, and we do it asynchronously for detach() and from
    // the position change notifications because those happen synchronously
    // during a frame, at a time where it's too late to call setState. Since the
    // result is usually animated, the lag incurred is no big deal.
    // SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
    //    coordinator.updateShadow();
    // });
  }

  Iterable<NestedScrollPosition> get nestedPositions {
    return Iterable.castFrom<ScrollPosition, NestedScrollPosition>(positions);
  }
}
