import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_ballistic_scroll_activity.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_child.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_controller.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_scroll_metrics.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_scroll_position.dart';

typedef _NestedScrollActivityGetter = ScrollActivity Function(NestedScrollPosition position);

class NestedInnerScrollCoordinator implements ScrollActivityDelegate, ScrollHoldController {
  NestedInnerScrollCoordinator(this._parent) {
    final double initialScrollOffset = _parent.initialScrollOffset;
    _outerController = NestedInnerScrollController(
      this,
      initialScrollOffset: initialScrollOffset,
      debugLabel: 'outer',
    );
    _innerController = NestedInnerScrollController(
      this,
      initialScrollOffset: 0.0,
      debugLabel: 'inner',
    );
  }

  //cache all inner scrollview
  final Map<Key, NestedScrollPosition> _innerScrollPositionMap = {};

  ScrollPosition? getInnerPosition(Key key) {
    return _innerScrollPositionMap[key];
  }

  void attachInnerScrollPosition(NestedScrollPosition position) {
    Key? scrollKey = _getInnerScrollViewKey(position);
    if (scrollKey != null) {
      //in case widget reuse cause multi keys point to same position
      _innerScrollPositionMap.removeWhere((key, value) => value == position);
      _innerScrollPositionMap[scrollKey] = position;
    }
  }

  void detachInnerScrollPosition(NestedScrollPosition position) {
    final removedKey = getRemovedKeyElement(position);

    if (removedKey != null) {
      _innerScrollPositionMap.remove(removedKey);
    }
  }

  Key? getRemovedKeyElement(NestedScrollPosition position) {
    try {
      Key removedKey = _innerScrollPositionMap.keys.firstWhere((key) => _innerScrollPositionMap[key] == position);
      return removedKey;
    } catch (_error) {
      return null;
    }
  }

  Key? _getInnerScrollViewKey(NestedScrollPosition position) {
    final context = position.context;
    if (context is ScrollableState) {
      NestedInnerScrollChild? innerScrollParentWidget = context.context.findAncestorWidgetOfExactType<NestedInnerScrollChild>();
      return innerScrollParentWidget?.scrollKey;
    }
    return null;
  }

  ScrollController _parent;

  late NestedInnerScrollController _outerController;

  NestedInnerScrollController get outerController => _outerController;

  late NestedInnerScrollController _innerController;

  NestedInnerScrollController get innerController => _innerController;

  //key to get scrolling innerview
  Key? innerTouchingKey;

  //[HOOK]return true when 1. user touch 2. fling
  bool get innerScroll {
    return innerTouchingKey != null || (innerPositions.isNotEmpty && getFirstIsScrollElement(innerPositions) != null);
  }

  NestedScrollPosition? getFirstIsScrollElement(Iterable<NestedScrollPosition> position) {
    try {
      NestedScrollPosition newPosition = position.firstWhere((element) => element.isScroll() == true);
      return newPosition;
    } catch (_error) {
      return null;
    }
  }

  NestedScrollPosition get _outerPosition {
    assert(_outerController.hasClients, "please ensure out scroll controller has clients");
    assert(_outerController.nestedPositions.length == 1, "outController has more than one client");
    return _outerController.position as NestedScrollPosition;
  }

  Iterable<NestedScrollPosition> get innerPositions {
    if (innerTouchingKey != null && _innerScrollPositionMap[innerTouchingKey] != null) {
      return Iterable.generate(1, (index) {
        return _innerScrollPositionMap[innerTouchingKey]!;
      });
    }
    return _innerController.nestedPositions;
  }

  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  void updateUserScrollDirection(ScrollDirection value) {
    if (userScrollDirection == value) return;
    _userScrollDirection = value;
    _outerPosition.didUpdateScrollDirection(value);
    for (var element in innerPositions) {
      element.didUpdateScrollDirection(value);
    }
  }

  ScrollDragController? _currentDrag;

  void beginActivity(ScrollActivity newOuterActivity, _NestedScrollActivityGetter innerActivityGetter) {
    _outerPosition.beginActivity(newOuterActivity);
    bool scrolling = newOuterActivity.isScrolling;

    //[HOOK]if we dont touch inner scrollview, disable it's activity consume
    if (innerScroll) {
      for (final NestedScrollPosition position in innerPositions) {
        final ScrollActivity newInnerActivity = innerActivityGetter(position);
        position.beginActivity(newInnerActivity);
        scrolling = newInnerActivity.isScrolling;
      }
    }
    _currentDrag?.dispose();
    _currentDrag = null;
    if (!scrolling) {
      updateUserScrollDirection(ScrollDirection.idle);
    }
  }

  @override
  AxisDirection get axisDirection => _outerPosition.axisDirection;

  static IdleScrollActivity _createIdleScrollActivity(NestedScrollPosition position) {
    return IdleScrollActivity(position);
  }

  @override
  void goIdle() {
    beginActivity(
      _createIdleScrollActivity(_outerPosition),
      _createIdleScrollActivity,
    );
  }

  @override
  void goBallistic(double velocity) {
    beginActivity(
      createOuterBallisticScrollActivity(velocity),
      (NestedScrollPosition position) => createInnerBallisticScrollActivity(position, velocity),
    );
  }

  ScrollActivity createOuterBallisticScrollActivity(double velocity) {
    final NestedScrollMetrics metrics = _getMetrics(_outerPosition, velocity);

    return _outerPosition.createBallisticScrollActivity(
      _outerPosition.physics.createBallisticSimulation(metrics, velocity),
      mode: NestedBallisticScrollActivityMode.outer,
      metrics: metrics,
    );
  }

  @protected
  ScrollActivity createInnerBallisticScrollActivity(NestedScrollPosition position, double velocity) {
    return position.createBallisticScrollActivity(
      position.physics.createBallisticSimulation(
        velocity == 0 ? position : _getMetrics(position, velocity),
        velocity,
      ),
      mode: NestedBallisticScrollActivityMode.inner,
    );
  }

  NestedScrollMetrics _getMetrics(NestedScrollPosition position, double velocity) {
    return NestedScrollMetrics(
      minScrollExtent: position.minScrollExtent,
      maxScrollExtent: position.maxScrollExtent,
      pixels: position.pixels,
      viewportDimension: position.viewportDimension,
      axisDirection: position.axisDirection,
      minRange: position.minScrollExtent,
      maxRange: position.maxScrollExtent,
      correctionOffset: 0,
    );
  }

  double unnestOffset(double value, NestedScrollPosition source) {
    if (source == _outerPosition) {
      return value.clamp(_outerPosition.minScrollExtent, _outerPosition.maxScrollExtent);
    }

    if (value < source.minScrollExtent) {
      return value - source.minScrollExtent + _outerPosition.minScrollExtent;
    }
    return value - source.minScrollExtent + _outerPosition.maxScrollExtent;
  }

  double nestOffset(double value, NestedScrollPosition target) {
    return value.clamp(target.minScrollExtent, target.maxScrollExtent);
  }

  @override
  double setPixels(double newPixels) {
    assert(false);
    return 0.0;
  }

  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    beginActivity(
      HoldScrollActivity(delegate: _outerPosition, onHoldCanceled: holdCancelCallback),
      (NestedScrollPosition position) => HoldScrollActivity(delegate: position),
    );
    return this;
  }

  @override
  void cancel() {
    goBallistic(0.0);
  }

  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    final ScrollDragController drag = ScrollDragController(
      delegate: this,
      details: details,
      onDragCanceled: dragCancelCallback,
    );
    beginActivity(
      DragScrollActivity(_outerPosition, drag),
      (NestedScrollPosition position) => DragScrollActivity(position, drag),
    );
    assert(_currentDrag == null);
    _currentDrag = drag;
    return drag;
  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    assert(delta != 0.0);
    final innerPositionList = innerPositions.toList();

    if (!innerScroll || innerPositionList.isEmpty) {
      _outerPosition.applyFullDragUpdate(delta);
    } else {
      double remainDelta = innerPositionList.first.applyClampedDragUpdate(delta);

      //[HOOK] when innerscrollview overscroll, outscrollview continues
      if (remainDelta != 0.0) {
        _outerPosition.applyFullDragUpdate(remainDelta);
      }
    }
  }

  void updateCanDrag(NestedScrollPosition position) {
    if (!position.haveDimensions) {
      return;
    }
    position.updateCanDrag(position.maxScrollExtent - position.minScrollExtent);
  }

  void setParent(ScrollController value) {
    _parent = value;
    updateParent();
  }

  void updateParent() {
    _outerPosition.setParent(_parent);
  }

  @mustCallSuper
  void dispose() {
    _innerScrollPositionMap.clear();
    _currentDrag?.dispose();
    _currentDrag = null;
    _outerController.dispose();
    _innerController.dispose();
  }

  @override
  String toString() => '${objectRuntimeType(this, 'NestedInnerScrollCoordinator')}(outer=$_outerController; inner=$_innerController)';
}
