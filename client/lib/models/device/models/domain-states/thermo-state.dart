import 'dart:convert';

class ThermoState {
  late double temp;
  late double hum;

  ThermoState(this.temp, this.hum);

  factory ThermoState.fromJson(String jsonState) {
    /*
    * {
    *  temp: "1.0",
    *  hum: "32.0",
    * }
    */

    final state = json.decode(jsonState);

    var tempJson = state['temp'] ?? "0.0";
    var humJson = state['hum'] ?? "0.0";

    var temp = tempJson is int ? (tempJson).toDouble() : tempJson;
    var hum = humJson is int ? (humJson).toDouble() : humJson;
    return new ThermoState(temp, hum);
  }

  @override
  String toString() {
    return "ThermoState: $temp°C, $hum%";
  }
}
