import 'dart:convert';

class CurtainState {
  late double progress;

  CurtainState(this.progress);

  factory CurtainState.fromJson(String jsonState) {
    /* Example curtain state
    * {
    *  speed: "1.0",
    * }
    */
    final state = json.decode(jsonState);

    var speedJson = state['speed'];
    var progress = speedJson is int ? (speedJson).toDouble() : speedJson;
    return CurtainState(progress);
  }
}
