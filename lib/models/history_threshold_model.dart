class HistoryThreshold {
  final double ph;
  final double tdsPpm;
  final double ecMsCm;
  final double tempC;

  HistoryThreshold({
    required this.ph,
    required this.tdsPpm,
    required this.ecMsCm,
    required this.tempC,
  });

  // Dari Map Firebase
  factory HistoryThreshold.fromMap(Map<String, dynamic> map) {
    return HistoryThreshold(
      ph: (map['ph'] as num?)?.toDouble() ?? 1.0,
      tdsPpm: (map['tds_ppm'] as num?)?.toDouble() ?? 50.0,
      ecMsCm: (map['ec_ms_cm'] as num?)?.toDouble() ?? 0.5,
      tempC: (map['temp_c'] as num?)?.toDouble() ?? 5.0,
    );
  }

  // Convert ke Map untuk simpan ke Firebase
  Map<String, dynamic> toMap() {
    return {'ph': ph, 'tds_ppm': tdsPpm, 'ec_ms_cm': ecMsCm, 'temp_c': tempC};
  }
}
