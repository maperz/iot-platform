import 'dart:convert';

class AirQualityState {
  late double temp;
  late double quality;

  AirQualityState(this.quality, this.temp);

  factory AirQualityState.fromJson(String jsonState) {
    /*
    * {
    *  temp: "1.0",
    *  quality: "1000",
    * }
    */

    final state = json.decode(jsonState);

    var tempJson = state['temp'] ?? 0.0;
    var qualityJson = state['quality'] ?? 0.0;

    var temp = tempJson is int ? (tempJson).toDouble() : tempJson;
    var quality = qualityJson is int ? (qualityJson).toDouble() : qualityJson;
    return AirQualityState(quality, temp);
  }

  @override
  String toString() {
    return "QualityState: ${quality}ppm $temp°C";
  }
}
