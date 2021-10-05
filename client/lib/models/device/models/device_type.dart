enum DeviceType {
  unknown,
  curtain,
  lamp,
  thermometer,
  switcher,
  distanceSensor
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
    default:
      return DeviceType.unknown;
  }
}
