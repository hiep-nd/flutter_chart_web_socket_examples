import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nd_core_utils/nd_disposable.dart';

class NDLogViewController extends NDDisposable {
  // NDDisposable
  @override
  void dispose() {
    updator = null;
  }

  List<String> get logs => _logs.toList(growable: false);
  void clear() {
    _logs.clear();
    updator?.call();
  }

  void log(dynamic value) {
    _logs.add(value.toString());
    updator?.call();
  }

  void Function()? updator;

  // Privates
  final List<String> _logs = [];
}

class NDLogView extends StatefulWidget {
  final NDLogViewController? controller;
  const NDLogView({Key? key, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NDLogViewState();
}

class _NDLogViewState extends State<NDLogView> {
  @override
  void initState() {
    super.initState();
    widget.controller?.updator = _updator;
  }

  @override
  void didUpdateWidget(covariant NDLogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?.updator = _updator;
  }

  @override
  void dispose() {
    widget.controller?.updator = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = widget.controller?.logs ?? [];
    return ListView.builder(
      controller: _controller,
      itemCount: logs.length,
      itemBuilder: (_, index) => Text(logs[index]),
    );
  }

  // Privates
  final _controller = ScrollController();

  void _updator() {
    setState(() {});
    Timer(const Duration(microseconds: 1000), () {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }
}
