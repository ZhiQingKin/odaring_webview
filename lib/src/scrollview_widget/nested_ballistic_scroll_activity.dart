

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_inner_scroll_coordinator.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_scroll_metrics.dart';
import 'package:odaring_web_view/src/scrollview_widget/nested_scroll_position.dart';

class NestedOuterBallisticScrollActivity extends BallisticScrollActivity {
  NestedOuterBallisticScrollActivity(
      this.coordinator,
      NestedScrollPosition position,
      this.metrics,
      Simulation simulation,
      TickerProvider vsync,
      )   : assert(metrics.minRange != metrics.maxRange),
        assert(metrics.maxRange > metrics.minRange),
        super(position, simulation, vsync);

  final NestedInnerScrollCoordinator coordinator;
  final NestedScrollMetrics metrics;

  @override
  NestedScrollPosition get delegate => super.delegate as NestedScrollPosition;

  @override
  void resetActivity() {
    delegate.beginActivity(
        coordinator.createOuterBallisticScrollActivity(velocity));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(
        coordinator.createOuterBallisticScrollActivity(velocity));
  }

  @override
  bool applyMoveTo(double value) {
    if (coordinator.innerScroll) {
      ///[HOOK]if fling inner scrollview at it's edge, enable out scrollview's fling effect
      if (coordinator.innerPositions.length == 1) {
        final p = coordinator.innerPositions.first;
        bool bottomOverscroll = velocity > 0 && p.pixels >= p.maxScrollExtent;
        bool topOverScroll = velocity < 0 && p.pixels <= p.minScrollExtent;

        if (!bottomOverscroll && !topOverScroll) {
          return false;
        } else {
          //enable out scrollview fling
        }
      }
    }
    bool done = false;
    if (velocity > 0.0) {
      if (value < metrics.minRange) return true;
      if (value > metrics.maxRange) {
        value = metrics.maxRange;
        done = true;
      }
    } else if (velocity < 0.0) {
      if (value > metrics.maxRange) return true;
      if (value < metrics.minRange) {
        value = metrics.minRange;
        done = true;
      }
    } else {
      value = value.clamp(metrics.minRange, metrics.maxRange);
      done = true;
    }
    final bool result = super.applyMoveTo(value + metrics.correctionOffset);
    assert(
    result); // since we tried to pass an in-range value, it shouldn't ever overflow
    return !done;
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, '_NestedOuterBallisticScrollActivity')}(${metrics.minRange} .. ${metrics.maxRange}; correcting by ${metrics.correctionOffset})';
  }
}

enum NestedBallisticScrollActivityMode { outer, inner, independent }

class NestedInnerBallisticScrollActivity extends BallisticScrollActivity {
  NestedInnerBallisticScrollActivity(
      this.coordinator,
      NestedScrollPosition position,
      Simulation simulation,
      TickerProvider vsync,
      ) : super(position, simulation, vsync);

  final NestedInnerScrollCoordinator coordinator;

  @override
  NestedScrollPosition get delegate => super.delegate as NestedScrollPosition;

  @override
  void resetActivity() {
    delegate.beginActivity(
        coordinator.createInnerBallisticScrollActivity(delegate, velocity));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(
        coordinator.createInnerBallisticScrollActivity(delegate, velocity));
  }

  @override
  bool applyMoveTo(double value) {
    return super.applyMoveTo(coordinator.nestOffset(value, delegate));
  }
}