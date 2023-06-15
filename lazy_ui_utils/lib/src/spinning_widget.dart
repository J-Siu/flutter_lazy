import 'package:lazy_extensions/lazy_extensions.dart' as lazy;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;

/// ### Lazy [SpinningWidget]
///
/// - Self contain spinning widget. No need to setup your own animation controller, just pass in [child] and a [ValueNotifier] for start/stop
/// - Specify minimum spin time before stop
class SpinningWidget extends StatefulWidget {
  /// Start/Stop the spinning
  /// - set [spin.value] = `true` to start spinning
  /// - set [spin.value] = `false` to stop spinning
  final ValueNotifier<bool>? spin;

  /// The spinning child widget
  final Widget child;

  /// Minimum spin time(in seconds) before actually stopping
  /// - Default 0sec
  final int minSyncSpinningSeconds;

  const SpinningWidget({
    Key? key,
    required this.child,
    this.minSyncSpinningSeconds = 0,
    this.spin,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpinningWidget();
}

class _SpinningWidget extends State<SpinningWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 30),
    vsync: this,
  );

  DateTime _spinStart = lazy.dayZero;

  @override
  void initState() {
    super.initState();
    widget.spin?.addListener(_spinHandler);
    _stop();
    // Check spin value, may started already
    if (widget.spin?.value == true) {
      _spin();
    }
  }

  @override
  void dispose() {
    String debugPrefix = '$runtimeType.dispose()';
    widget.spin?.removeListener(_spinHandler);
    // Controller must be disposed
    try {
      _controller.dispose();
    } catch (e) {
      // Do nothing. _controller disposed already.
      lazy.log('$debugPrefix:catch:$e -> Do nothing. _controller disposed.');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Spin(
      controller: _controller,
      child: widget.child,
    );
  }

  void _spin() async {
    String debugPrefix = '$runtimeType._spin()';
    lazy.log(debugPrefix);
    _spinStart = lazy.now;
    try {
      _controller.repeat();
    } catch (e) {
      // Do nothing. _controller disposed already.
      lazy.log('$debugPrefix:catch:$e -> Do nothing. _controller disposed.');
    }
  }

  void _stop() async {
    String debugPrefix = '$runtimeType.stop()';
    lazy.log(debugPrefix);
    // Don't stop spinning if < [widget.minSyncSpinningSeconds]
    var syncDuration = DateTime.now().difference(_spinStart);
    if (syncDuration.inSeconds < widget.minSyncSpinningSeconds) {
      var delay = widget.minSyncSpinningSeconds - syncDuration.inSeconds;
      lazy.log('$debugPrefix:spinning stop delay $delay seconds');
      await Future.delayed(Duration(seconds: delay));
    }
    // If widget disposed before timer run out, _controller maybe gone already
    try {
      _controller.stop(canceled: false);
    } catch (e) {
      // Do nothing. _controller disposed already.
      lazy.log('$debugPrefix:catch:$e -> Do nothing. _controller disposed.');
    }
    lazy.log('$debugPrefix:spinning stopped');
  }

  void _spinHandler() async {
    String debugPrefix = '$runtimeType._spinHandler()';
    lazy.log(debugPrefix);
    if (widget.spin?.value == true) {
      _spin();
    } else {
      _stop();
    }
  }
}

class _Spin extends AnimatedWidget {
  final Widget child;

  const _Spin({
    Key? key,
    required AnimationController controller,
    required this.child,
  }) : super(key: key, listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _progress.value * 2.5 * math.pi,
      child: child,
    );
  }
}
