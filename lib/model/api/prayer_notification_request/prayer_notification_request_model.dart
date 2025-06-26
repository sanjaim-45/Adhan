class PrayerNotificationRequest {
  final int customerId;
  final String androidDeviceToken;
  final bool isPrayerNotificationEnabled;

  PrayerNotificationRequest({
    required this.customerId,
    required this.androidDeviceToken,
    required this.isPrayerNotificationEnabled,
  });

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'androidDeviceToken': androidDeviceToken,
    'isMobileNotificationEnabled': isPrayerNotificationEnabled,
  };
}
