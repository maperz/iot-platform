import 'dart:convert';

class AirQualityState {
  late double temp;
  late double hum;
  late double quality;
  late double organic;

  AirQualityState(this.quality, this.organic, this.temp, this.hum);

  factory AirQualityState.fromJson(String jsonState) {
    /*
    * {
    *  temp: "1.0",
    *  quality: "1000",
    * }
    */

    final state = json.decode(jsonState);

    var tempJson = state['temp'] ?? 0.0;
    var humJson = state['hum'] ?? 0.0;
    var organicJson = state['organic'] ?? 0.0;
    var qualityJson = state['quality'] ?? 0.0;

    var temp = tempJson is int ? (tempJson).toDouble() : tempJson;
    var hum = humJson is int ? (humJson).toDouble() : humJson;
    var quality = qualityJson is int ? (qualityJson).toDouble() : qualityJson;
    var organic = organicJson is int ? (organicJson).toDouble() : organicJson;

    return AirQualityState(quality, organic, temp, hum);
  }

  @override
  String toString() {
    return "QualityState: ${quality}ppm $temp°C";
  }
}
