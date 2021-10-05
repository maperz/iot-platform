import 'package:charts_flutter/flutter.dart' as charts;
import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/thermo_state.dart';
import 'package:flutter/material.dart';

class ThermoDetailPage extends StatefulWidget {
  late final List<charts.Series<ThermoTimeData, DateTime>> seriesList;
  final bool animate;

  ThermoDetailPage(List<ThermoTimeData> data, {Key? key, required this.animate})
      : super(key: key) {
    seriesList = [
      charts.Series<ThermoTimeData, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ThermoTimeData sales, _) => sales.time,
        measureFn: (ThermoTimeData sales, _) => sales.state.temp,
        data: data,
      )
      /*,new charts.Series<ThermoTimeData, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (ThermoTimeData sales, _) => sales.time,
        measureFn: (ThermoTimeData sales, _) => sales.state.hum,
        data: data,
      ),*/
    ];
  }

  factory ThermoDetailPage.fromDeviceHistory(
      Iterable<DeviceState> deviceStateHistory) {
    var data = deviceStateHistory
        .map((state) =>
            ThermoTimeData(state.lastUpdate, ThermoState.fromJson(state.state)))
        .toList();

    return ThermoDetailPage(
      data,
      animate: true,
    );
  }

  factory ThermoDetailPage.withSampleData() {
    return ThermoDetailPage(
      _createSampleData(),
      animate: true,
    );
  }

  @override
  _ThermoDetailPageState createState() => _ThermoDetailPageState();

  /// Create one series with sample hard coded data.
  static List<ThermoTimeData> _createSampleData() {
    final data = [
      ThermoTimeData(DateTime(2021, 8, 20), ThermoState(25, 70)),
      ThermoTimeData(DateTime(2021, 8, 21), ThermoState(26, 80)),
      ThermoTimeData(DateTime(2021, 8, 22), ThermoState(25.4, 80)),
      ThermoTimeData(DateTime(2021, 8, 23), ThermoState(23.2, 80)),
      ThermoTimeData(DateTime(2021, 8, 24), ThermoState(27.2, 80)),
      ThermoTimeData(DateTime(2021, 8, 25), ThermoState(21.2, 80)),
      ThermoTimeData(DateTime(2021, 8, 26), ThermoState(28.2, 80)),
    ];

    return data;
  }
}

class _ThermoDetailPageState extends State<ThermoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(widget.seriesList,
        defaultRenderer:
            charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: widget.animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        domainAxis: charts.DateTimeAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
              labelStyle: const charts.TextStyleSpec(
                fontSize: 10,
                color: charts.MaterialPalette.white,
              ),
              lineStyle: charts.LineStyleSpec(
                color: charts.MaterialPalette.gray.shadeDefault,
              )),
          tickProviderSpec: const charts.AutoDateTimeTickProviderSpec(),
          tickFormatterSpec: const charts.AutoDateTimeTickFormatterSpec(
            day: charts.TimeFormatterSpec(
              format: 'dd MMM',
              transitionFormat: 'dd MMM',
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: const charts.BasicNumericTickProviderSpec(
              zeroBound: false, desiredTickCount: 5),
          renderSpec: charts.GridlineRendererSpec(
              labelStyle: const charts.TextStyleSpec(
                fontSize: 10,
                color: charts.MaterialPalette.white,
              ),
              lineStyle: charts.LineStyleSpec(
                color: charts.MaterialPalette.gray.shadeDefault,
              )),
        ));
  }
}

class ThermoTimeData {
  final DateTime time;
  final ThermoState state;

  ThermoTimeData(this.time, this.state);
}
