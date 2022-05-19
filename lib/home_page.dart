import 'package:chart_web_socket_examples/chart_example_page.dart';
import 'package:chart_web_socket_examples/web_socket_example_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart and WebSocket Examples'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              _buildItem(
                'Web Socket',
                context,
                (_) => const WebSocketExamplePage(),
              ),
              _buildItem(
                'Chart',
                context,
                (_) => const ChartExamplePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Privates
  Widget _buildItem(String text, BuildContext context, WidgetBuilder builder) =>
      TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: builder,
              ),
            );
          },
          child: Text(text));
}
