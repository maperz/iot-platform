import 'dart:convert';

class DistanseSensorState {
  late double distance;
  // late double change;

  DistanseSensorState(this.distance);

  factory DistanseSensorState.fromJson(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var tempJson = state['distance'] ?? "0.0";
    var distance = tempJson is int ? (tempJson).toDouble() : tempJson;
    return DistanseSensorState(distance);
  }
}
