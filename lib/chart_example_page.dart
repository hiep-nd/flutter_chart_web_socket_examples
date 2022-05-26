import 'dart:math';

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
    Widget _buildRandomChart() {
      final random = Random();
      return Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          width: 50,
          height: 33,
          child: _buildLineChart(
            data: (() {
              final builder = <_Point>[];
              final start = random.nextInt(5);
              for (int i = start; i < start + 10; i++) {
                builder.add(_Point(
                    domain: i.toDouble(), measure: random.nextInt(1000) / 10));
              }
              return builder;
            })(),
            base: random.nextInt(1000) / 20,
            domainFn: _Point.getDomain,
            measureFn: _Point.getMeasure,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Example'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: (() {
              final builder = <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Reload'),
                )
              ];

              for (int i = 0; i < 10; i++) {
                builder.add(_buildRandomChart());
              }
              return builder;
            })(),
          ),
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
  late final IOWebSocketChannel _channel;

  Widget _buildLineChart<D>({
    required List<D> data,
    required double base,
    required charts.TypedAccessorFn<D, double> domainFn,
    required charts.TypedAccessorFn<D, double> measureFn,
  }) {
    final measures = data.map((e) => measureFn(e, null));
    final minM = measures.fold<double>(double.infinity, min);
    final maxM = measures.fold<double>(double.negativeInfinity, max);

    final deltaM = min(base, minM);

    final domains = data.map((e) => domainFn(e, null));
    final minD = domains.fold<double>(double.infinity, min);
    final maxD = domains.fold<double>(double.negativeInfinity, max);

    final lastM = measureFn(data.last, data.length - 1);
    final color = lastM > base
        ? const charts.Color(r: 0x2E, g: 0xBD, b: 0x85)
        : lastM == base
            ? const charts.Color(r: 0xF1, g: 0xCE, b: 0x5F)
            : const charts.Color(r: 0xE7, g: 0x59, b: 0x6A);

    return charts.LineChart(
      [
        charts.Series<_Point, double>(
          id: 'Base',
          data: [
            _Point(domain: 0, measure: base),
            _Point(domain: 15, measure: base),
          ],
          domainFn: _Point.getDomain,
          measureFn: (datum, index) =>
              0, // _Point.getMeasure(datum, index) - deltaM,
          colorFn: (_, __) => const charts.Color(r: 0xC7, g: 0xC7, b: 0xCC),
          areaColorFn: (_, __) => charts.Color.transparent,
          dashPatternFn: (_, __) => [4, 4],
          strokeWidthPxFn: (datum, index) => 1,
        ),
        charts.Series<D, double>(
          id: 'Price',
          data: data,
          domainFn: domainFn,
          measureFn: (datum, index) => measureFn(datum, index) - deltaM - base,
          // measureLowerBoundFn: (_, __) => 100, // minM - deltaM,
          // measureUpperBoundFn: (datum, index) =>
          //     measureFn(datum, index) - deltaM, //(_, __) => maxM - deltaM,
          colorFn: (_, __) => color,
          // areaColorFn: (value, index) =>
          //     charts.Color(r: 0x2E, g: 0x00, b: 0x85, a: 25),
          strokeWidthPxFn: (datum, index) => 1,
          // fillColorFn: (value, index) =>
          // charts.Color(r: 0xFE, g: 0xBD, b: 0x85),
        ),
      ],
      animate: true,
      domainAxis: const charts.NumericAxisSpec(
          showAxisLine: false, renderSpec: charts.NoneRenderSpec()),
      primaryMeasureAxis: const charts.NumericAxisSpec(
          showAxisLine: false, renderSpec: charts.NoneRenderSpec()),
      layoutConfig: charts.LayoutConfig(
        leftMarginSpec: charts.MarginSpec.fixedPixel(0),
        rightMarginSpec: charts.MarginSpec.fixedPixel(0),
        topMarginSpec: charts.MarginSpec.fixedPixel(0),
        bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
      ),
      defaultRenderer: charts.LineRendererConfig(
        // roundEndCaps: true,
        includeArea: true,
        // areaOpacity: 0.2,
        // stacked: true,
      ),
    );
  }
}

class _Point {
  final double domain;
  final double measure;

  _Point({required this.domain, required this.measure});

  static double getDomain(_Point p, int? _) => p.domain;
  static double getMeasure(_Point p, int? _) => p.measure;
}

class Price {
  final int time;
  final double price;

  Price({required this.time, required this.price});
}
