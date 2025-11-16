class ConfigModel {
  double phMin;
  double phMax;
  double tdsMin;
  double tdsMax;
  double ecMin;
  double ecMax;
  double tempMin;
  double tempMax;
  bool isManual;
  int lightOnHour;
  int lightOffHour;

  ConfigModel({
    required this.phMin,
    required this.phMax,
    required this.tdsMin,
    required this.tdsMax,
    required this.ecMin,
    required this.ecMax,
    required this.tempMin,
    required this.tempMax,
    required this.isManual,
    required this.lightOnHour,
    required this.lightOffHour,
  });

  factory ConfigModel.fromMap(Map<dynamic, dynamic> map) {
    return ConfigModel(
      phMin: (map['ph_min'] ?? 0).toDouble(),
      phMax: (map['ph_max'] ?? 0).toDouble(),
      tdsMin: (map['tds_min_ppm'] ?? 0).toDouble(),
      tdsMax: (map['tds_max_ppm'] ?? 0).toDouble(),
      ecMin: (map['ec_min_ms_cm'] ?? 0).toDouble(),
      ecMax: (map['ec_max_ms_cm'] ?? 0).toDouble(),
      tempMin: (map['temp_min_c'] ?? 0).toDouble(),
      tempMax: (map['temp_max_c'] ?? 0).toDouble(),
      isManual: map['is_manual'] ?? true,
      lightOnHour: map['light_on_hour'] ?? 6,
      lightOffHour: map['light_off_hour'] ?? 18,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ph_min': phMin,
      'ph_max': phMax,
      'tds_min_ppm': tdsMin,
      'tds_max_ppm': tdsMax,
      'ec_min_ms_cm': ecMin,
      'ec_max_ms_cm': ecMax,
      'temp_min_c': tempMin,
      'temp_max_c': tempMax,
      'is_manual': isManual,
      'light_on_hour': lightOnHour,
      'light_off_hour': lightOffHour,
    };
  }
}
