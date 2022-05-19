import 'dart:convert';

import 'package:chart_web_socket_examples/nd_log_view.dart';
import 'package:flutter/material.dart';
import 'package:nd_core_utils/nd_auto_disposable.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';

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
                builder: (_, value, ___) =>
                    value == _WebSocketExamplePageStateStatus.connected
                        ? _buildMessage()
                        : _buildUrl(),
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
    _logger.value = null;

    _channel?.sink.close(goingAway);
    _channel = null;

    _msgController.dispose();
    _headerController.dispose();
    _urlController.dispose();
    _status.dispose();

    super.dispose();
  }

  // Privates
  final ValueNotifier<_WebSocketExamplePageStateStatus> _status =
      ValueNotifier(_WebSocketExamplePageStateStatus.disconnected);
  final _urlController = TextEditingController(
      text:
          'wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self');
  final _headerController = TextEditingController();
  final _msgController = TextEditingController();
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

  Widget _buildText(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white),
      );

  Widget _buildUrl() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Enter your websocket url and connect'),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 8),
        _buildText('Headers'),
        SizedBox(
          height: 100,
          child: TextField(
            controller: _headerController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
            ),
            maxLines: null,
            expands: true,
          ),
        ),
        _buildButton('Connect', Colors.indigo.shade600, () {
          final url = _urlController.text;
          late final Map<String, dynamic>? header;
          try {
            header =
                jsonDecode(_headerController.text) as Map<String, dynamic>?;
          } catch (_) {
            header = null;
          }

          _logger.value?.log('- Connecting to: $url');
          _channel?.sink.close(goingAway);
          _channel =
              IOWebSocketChannel.connect(_urlController.text, headers: header);
          _channel?.stream.listen((event) {
            _logger.value?.log('▼$event');
          }, onDone: () {
            _status.value = _WebSocketExamplePageStateStatus.disconnected;
            _logger.value?.log('- Connection closed');
          }, onError: (err) {
            _status.value = _WebSocketExamplePageStateStatus.disconnected;
            _logger.value?.log('- Connection Error: \'$err\'');
          });
          _status.value = _WebSocketExamplePageStateStatus.connected;
          _logger.value?.log('- Connection established');
        })
      ],
    );
  }

  Widget _buildMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Status: connected'),
        TextField(
          controller: _msgController,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
          ),
        ),
        const SizedBox(width: 16),
        _buildButton('Send', Colors.indigo.shade600, () {
          _logger.value?.log('▲${_msgController.text}');
          _channel?.sink.add(_msgController.text);
        }),
        _buildButton('Disconnect', Colors.red.shade700, () {
          _channel?.sink.close(goingAway);
          _channel = null;
        }),
      ],
    );
  }
}
