import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nd_core_utils/nd_auto_disposable.dart';
import 'package:nd_core_utils/nd_disposable.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chart and WebSocket Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart and WebSocket Examples'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const WebSocketExamplePage()));
                },
                child: const Text('Web Socket'))
          ],
        ),
      ),
    );
  }
}

class WebSocketExamplePage extends StatefulWidget {
  const WebSocketExamplePage({Key? key}) : super(key: key);

  @override
  State<WebSocketExamplePage> createState() => _WebSocketExamplePageState();
}

enum _WebSocketExamplePageStateStatus { connected, disconnected }

class _WebSocketExamplePageState extends State<WebSocketExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Socket Example'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _status,
                builder: (_, value, ___) {
                  if (value == _WebSocketExamplePageStateStatus.connected) {
                    return const Text(
                      'Status: connected',
                      style: TextStyle(color: Colors.white),
                    );
                  } else {
                    return const Text(
                      'Enter your websocket url and connect',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    );
                  }
                },
              ),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(width: 16),
              ValueListenableBuilder(
                valueListenable: _status,
                builder: (_, value, __) {
                  if (value == _WebSocketExamplePageStateStatus.connected) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildButton('Send', Colors.indigo.shade600, () {
                          _logger.value?.log('▲${_controller.text}');
                          _channel?.sink.add(_controller.text);
                        }),
                        _buildButton('Disconnect', Colors.red.shade700, () {
                          _channel?.sink.close(goingAway);
                          _channel = null;
                          _status.value =
                              _WebSocketExamplePageStateStatus.disconnected;
                          _logger.value?.log('- Connection closed');
                          _controller.text =
                              'wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self';
                        }),
                      ],
                    );
                  } else {
                    return _buildButton('Connect', Colors.indigo.shade600, () {
                      _logger.value
                          ?.log('- Connecting to: ${_controller.text}');
                      _channel?.sink.close(goingAway);
                      _channel = IOWebSocketChannel.connect(_controller.text);
                      _channel?.stream.listen((event) {
                        _logger.value?.log('▼$event');
                      });
                      _status.value =
                          _WebSocketExamplePageStateStatus.connected;
                      _logger.value?.log('- Connection established');
                      _controller.text = '';
                    });
                  }
                },
              ),
              Expanded(
                  child: Container(
                color: Colors.white,
                child: NDLogView(
                  controller: _logger.value,
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close(goingAway);
    _channel = null;
    super.dispose();
  }

  // Privates
  final ValueNotifier<_WebSocketExamplePageStateStatus> _status =
      ValueNotifier(_WebSocketExamplePageStateStatus.disconnected);
  final _controller = TextEditingController(
      text:
          'wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self');
  IOWebSocketChannel? _channel;
  final _logger = NDAutoDisposable(NDLogViewController());

  Widget _buildButton(String text, Color color, void Function() onPressed) =>
      TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        style: TextButton.styleFrom(backgroundColor: color),
      );
}

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
