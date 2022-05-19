import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';

class ChartExamplePage extends StatefulWidget {
  const ChartExamplePage({Key? key}) : super(key: key);

  @override
  State<ChartExamplePage> createState() => _ChartExamplePageState();
}

class _ChartExamplePageState extends State<ChartExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Example'),
      ),
      body: SafeArea(
        child: charts.LineChart(
          [_prices, _bases],
          animate: true,
          domainAxis:
              const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
          primaryMeasureAxis:
              const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
          // secondaryMeasureAxis: charts.NumericAxisSpec(showAxisLine: false),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect(
        'wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self');
    _channel.stream.listen((event) {
      if (event is String) {}
    });
  }

  @override
  void dispose() {
    _channel.sink.close(goingAway);
    super.dispose();
  }

  // Privates
  final charts.Series<Price, int> _prices = charts.Series(
    id: 'STR',
    data: [
      Price(time: 0, price: 100),
      Price(
        time: 1,
        price: 200,
      ),
      Price(
        time: 20,
        price: 400,
      ),
    ],
    domainFn: (datum, _) => datum.time,
    measureFn: (datum, index) => datum.price,
    colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
  );
  final charts.Series<Price, int> _bases = charts.Series(
    id: 'base',
    data: [
      Price(time: 0, price: 250),
      Price(
        time: 20,
        price: 250,
      ),
    ],
    domainFn: (datum, _) => datum.time,
    measureFn: (datum, index) => datum.price,
    colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
    dashPatternFn: (datum, index) => [20, 2],
  );
  late final IOWebSocketChannel _channel;
}

class Price {
  final int time;
  final double price;

  Price({required this.time, required this.price});
}
