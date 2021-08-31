import 'dart:convert';
import 'dart:ui';

import 'package:curtains_client/utils/colors.dart';

class LampState {
  late bool isOn;
  late Color color;

  LampState(this.isOn, this.color);

  factory LampState.fromJson(String jsonState) {
    /* Example lamp state
    * {
    *  isOn: true/false,
    *  color: "#000000"
    * }
    */

    final state = json.decode(jsonState);
    final isOn = state["isOn"];
    final color = hexToColor(state["color"]);

    return LampState(isOn, color);
  }
}
