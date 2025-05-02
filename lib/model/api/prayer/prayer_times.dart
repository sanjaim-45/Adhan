// lib/models/prayer_times_model.dart
class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json['fajr'] ?? '--:--',
      dhuhr: json['dhuhr'] ?? '--:--',
      asr: json['asr'] ?? '--:--',
      maghrib: json['maghrib'] ?? '--:--',
      isha: json['isha'] ?? '--:--',
    );
  }

  Map<String, String> toMap() {
    return {
      'Fajr': fajr,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }
}