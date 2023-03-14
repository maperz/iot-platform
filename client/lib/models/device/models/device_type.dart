enum DeviceType {
  unknown,
  curtain,
  lamp,
  thermometer,
  switcher,
  distanceSensor,
  airqualitySensor,
  blind
}

extension DeviceTypeNameExtesion on DeviceType {
  String getName() {
    switch (this) {
      case DeviceType.curtain:
        return "Curtain";
      case DeviceType.lamp:
        return "Lamp";
      case DeviceType.switcher:
        return "Switch";
      case DeviceType.thermometer:
        return "Thermometer";
      case DeviceType.airqualitySensor:
        return "Air Quality";
      case DeviceType.blind:
        return "Blind";
      default:
        return 'Unknown';
    }
  }
}

DeviceType parseDeviceType(String type) {
  switch (type.toLowerCase().trim()) {
    case "curtain":
      return DeviceType.curtain;
    case "lamp":
      return DeviceType.lamp;
    case "switch":
      return DeviceType.switcher;
    case "thermo":
      return DeviceType.thermometer;
    case "distance-measure":
      return DeviceType.distanceSensor;
    case "airquality":
      return DeviceType.airqualitySensor;
    case "blind":
      return DeviceType.blind;
    default:
      return DeviceType.unknown;
  }
}
