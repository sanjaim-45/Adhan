import '../../model/api/prayer/prayer_times.dart';

class PrayerTimesCache {
  static final PrayerTimesCache _instance = PrayerTimesCache._internal();
  factory PrayerTimesCache() => _instance;
  PrayerTimesCache._internal();

  final Map<String, PrayerTimes> _cache = {};

  void storePrayerTimes(DateTime date, PrayerTimes times) {
    final key = _formatDate(date);
    _cache[key] = times;
  }

  PrayerTimes? getPrayerTimes(DateTime date) {
    final key = _formatDate(date);
    return _cache[key];
  }

  void clearPrayerTimes(DateTime date) {
    final key = _formatDate(date);
    _cache.remove(key);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
