import 'dart:convert';

class BlindState {
  BlindState();

  factory BlindState.fromJson(String jsonState) {
    /*
    * {
    *  temp: "1.0",
    *  hum: "32.0",
    * }
    */

    final state = json.decode(jsonState);
    // var temp = tempJson is int ? (tempJson).toDouble() : tempJson;
    // var hum = humJson is int ? (humJson).toDouble() : humJson;
    return BlindState();
  }

  @override
  String toString() {
    return "BlindState: ";
  }
}
