class DeviceModel {
  bool pumpAcid;
  bool pumpNutrient;
  bool lamp;

  DeviceModel({
    required this.pumpAcid,
    required this.pumpNutrient,
    required this.lamp,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      pumpAcid: map['pump_acid'] ?? false,
      pumpNutrient: map['pump_nutrient'] ?? false,
      lamp: map['lamp'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'pump_acid': pumpAcid, 'pump_nutrient': pumpNutrient, 'lamp': lamp};
  }
}
