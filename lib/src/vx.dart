library vx;

import 'package:flutter/widgets.dart';

BuildContext? currentContext;

class Vx<T> {
  Vx(this._value);

  T _value;
  final Set<WeakReference<RxState>> _listeners = {};

  T get value {
    if (currentContext != null) {
      _listeners.add(
          WeakReference((currentContext as StatefulElement).state as RxState));
    }
    return _value;
  }

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notify();
    }
  }

  void notify() {
    for (final listener in _listeners) {
      listener.target?.notify();
    }
    _listeners.clear();
  }
}

class SxWidget extends StatefulWidget {
  final WidgetBuilder Function(SxState) initializer;

  const SxWidget(this.initializer, {super.key});

  @override
  SxState createState() => SxState();
}

class SxState extends RxState<SxWidget> {
  late final WidgetBuilder _build;
  VoidCallback? onDidChangeDependencies;
  VoidCallback? onDidUpdateWidget;
  VoidCallback? onDeactivate;
  VoidCallback? onDispose;

  @override
  void initState() {
    super.initState();
    _build = widget.initializer(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onDidChangeDependencies?.call();
  }

  @override
  void didUpdateWidget(SxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    onDidUpdateWidget?.call();
  }

  @override
  Widget buildInner(BuildContext context) => _build(context);

  @override
  void deactivate() {
    onDeactivate?.call();
    super.deactivate();
  }

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
}

class BxWidget extends StatefulWidget {
  final WidgetBuilder builder;

  const BxWidget(this.builder, {super.key});

  @override
  State<StatefulWidget> createState() => BxState();
}

class BxState extends RxState<BxWidget> {
  @override
  Widget buildInner(BuildContext context) => widget.builder(context);
}

abstract class RxState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    final lastContext = currentContext;
    currentContext = context;
    try {
      return buildInner(context);
    } finally {
      currentContext = lastContext;
    }
  }

  void notify() => super.setState(() {});

  Widget buildInner(BuildContext context);
}
