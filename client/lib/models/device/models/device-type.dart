enum DeviceType { Unknown, Curtain, Lamp, Thermo, Switch, DistanceSensor }

extension DeviceTypeNameExtesion on DeviceType {
  String getName() {
    switch (this) {
      case DeviceType.Curtain:
        return "Curtain";
      case DeviceType.Lamp:
        return "Lamp";
      case DeviceType.Switch:
        return "Switch";
      case DeviceType.Thermo:
        return "Thermometer";
      default:
        return 'Unknown';
    }
  }
}

DeviceType parseDeviceType(String type) {
  switch (type.toLowerCase().trim()) {
    case "curtain":
      return DeviceType.Curtain;
    case "lamp":
      return DeviceType.Lamp;
    case "switch":
      return DeviceType.Switch;
    case "thermo":
      return DeviceType.Thermo;
    case "distance-measure":
      return DeviceType.DistanceSensor;
    default:
      return DeviceType.Unknown;
  }
}
