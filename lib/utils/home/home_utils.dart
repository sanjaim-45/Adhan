import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import '../../model/api/prayer/prayer_times.dart';

class HomeUtils {
  // Singleton instance
  static final HomeUtils _instance = HomeUtils._internal();
  factory HomeUtils() => _instance;
  HomeUtils._internal();

  // Permission request state management
  static Completer<bool>? _permissionRequestCompleter;
  static bool _isDialogShowing = false;
  static DateTime? _lastPermissionRequestTime;

  String formatCountdown(Duration duration) {
    if (duration.inDays > 0) {
      return "${duration.inDays}d ${duration.inHours % 24}h";
    } else if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes % 60}m";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes}m ${duration.inSeconds % 60}s";
    } else {
      return "${duration.inSeconds}s";
    }
  }

  static Stream<geo.ServiceStatus> get locationServiceStatusStream {
    return geo.Geolocator.getServiceStatusStream();
  }

  static Future<bool> checkLocationPermissionAndService(
    BuildContext context,
  ) async {
    return _checkWithDebounce(context, _performPermissionCheck);
  }

  static Future<bool> checkLocationPermission(BuildContext context) async {
    return _checkWithDebounce(context, _performPermissionCheck);
  }

  static Future<bool> _checkWithDebounce(
    BuildContext context,
    Future<bool> Function(BuildContext) checkFunction,
  ) async {
    // Debounce rapid successive calls
    if (_lastPermissionRequestTime != null &&
        DateTime.now().difference(_lastPermissionRequestTime!) <
            const Duration(seconds: 1)) {
      return false;
    }
    _lastPermissionRequestTime = DateTime.now();

    // If a request is already in progress, return its future
    if (_permissionRequestCompleter != null) {
      return _permissionRequestCompleter!.future;
    }

    _permissionRequestCompleter = Completer<bool>();
    try {
      final result = await checkFunction(context);
      _permissionRequestCompleter!.complete(result);
      return result;
    } catch (e) {
      debugPrint('Permission check error: $e');
      _permissionRequestCompleter!.complete(false);
      return false;
    } finally {
      _permissionRequestCompleter = null;
    }
  }

  static Future<bool> _performPermissionCheck(BuildContext context) async {
    try {
      if (_isDialogShowing) {
        debugPrint("Dialog is already showing. New check ignored.");
        return false;
      }

      // Check if location services are enabled
      final serviceEnabled = await Permission.location.serviceStatus.isEnabled;
      if (!serviceEnabled) {
        if (!_isDialogShowing) {
          await _showLocationOverlay(context);
          _isDialogShowing = true;
        }
        return false;
      }

      // Check location permission status
      final status = await Permission.location.status;
      if (!status.isGranted) {
        final result = await Permission.location.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          if (!_isDialogShowing) {
            await showPermissionDeniedDialog(context);
            _isDialogShowing = true;
          }
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Location permission check error: $e');
      return false;
    }
  }

  static Future<void> _showLocationOverlay(BuildContext context) async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    try {
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) {
            final locationServiceSubscription =
                Geolocator.getServiceStatusStream().listen((status) {
                  if (status == ServiceStatus.enabled && _isDialogShowing) {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  }
                });

            return LocationPermissionOverlay(
              onRetry: () => checkLocationPermissionAndService(context),
              onDispose: () => locationServiceSubscription.cancel(),
            );
          },
        ),
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  Map<String, dynamic> getNextPrayer(PrayerTimes prayerTimes, DateTime now) {
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final prayers = [
      {
        'name': 'Fajr',
        'arabic': 'الفجر',
        'time': _parsePrayerTime('$dateStr ${prayerTimes.fajr}'),
        'imagePath': 'assets/images/cloud/Sunny.png',
      },
      {
        'name': 'Dhuhr',
        'arabic': 'الظهر',
        'time': _parsePrayerTime('$dateStr ${prayerTimes.dhuhr}'),
        'imagePath': 'assets/images/cloud/Partly-cloudy.png',
      },
      {
        'name': 'Asr',
        'arabic': 'العصر',
        'time': _parsePrayerTime('$dateStr ${prayerTimes.asr}'),
        'imagePath': 'assets/images/cloud/Cloudy-clear at times-night.png',
      },
      {
        'name': 'Maghrib',
        'arabic': 'المغرب',
        'time': _parsePrayerTime('$dateStr ${prayerTimes.maghrib}'),
        'imagePath': 'assets/images/cloud/Cloudy-clear at times.png',
      },
      {
        'name': 'Isha',
        'arabic': 'العشاء',
        'time': _parsePrayerTime('$dateStr ${prayerTimes.isha}'),
        'imagePath': 'assets/images/cloud/Clear-night.png',
      },
    ];

    final validPrayers = prayers.where((p) => p['time'] != null).toList();
    validPrayers.sort(
      (a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime),
    );

    for (var prayer in validPrayers) {
      if ((prayer['time'] as DateTime).isAfter(now)) {
        return prayer;
      }
    }

    final nextFajrTime = _parsePrayerTime('$dateStr ${prayerTimes.fajr}');
    return {
      'name': 'Fajr',
      'arabic': 'الفجر',
      'time':
          nextFajrTime?.add(const Duration(days: 1)) ??
          DateTime.now().add(const Duration(days: 1)),
      'imagePath': 'assets/images/cloud/Clear-night.png',
    };
  }

  DateTime? _parsePrayerTime(String timeString) {
    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  static Future<void> showEnableLocationDialog(BuildContext context) async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => WillPopScope(
              onWillPop: () async {
                _isDialogShowing = false;
                return true;
              },
              child: AlertDialog(
                title: const Text('Location Services Disabled'),
                content: const Text(
                  'Please enable location services to get accurate prayer times.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _isDialogShowing = false;
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      _isDialogShowing = false;
                      await openAppSettings();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => WillPopScope(
              onWillPop: () async {
                _isDialogShowing = false;
                return true;
              },
              child: AlertDialog(
                title: const Text('Location Permission Denied'),
                content: const Text(
                  'Please grant location permission to get accurate prayer times.',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      _isDialogShowing = false;
                      await openAppSettings();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
      );
    } finally {
      _isDialogShowing = false;
    }
  }
}

class LocationPermissionOverlay extends StatefulWidget {
  final VoidCallback onRetry;
  final VoidCallback onDispose;

  const LocationPermissionOverlay({
    super.key,
    required this.onRetry,
    required this.onDispose,
  });

  @override
  _LocationPermissionOverlayState createState() =>
      _LocationPermissionOverlayState();
}

class _LocationPermissionOverlayState extends State<LocationPermissionOverlay> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 50, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Location Services Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enable location services to use all features of this app.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      HomeUtils._isDialogShowing = false;
                    },
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();
                      Navigator.pop(context);
                      widget.onRetry();
                    },
                    child: const Text('Enable Location'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
