import 'package:flutter/material.dart';
import 'package:prayerunitesss/model/api/subscription/current_subscription_model.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../service/api/templete_api/api_service.dart';

class SubscriptionProvider with ChangeNotifier {
  CurrentSubscriptionModel? _subscription;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasNoSubscription = false;
  DateTime? _lastFetchTime;
  bool _isFetching = false;

  CurrentSubscriptionModel? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasNoSubscription => _hasNoSubscription;

  Future<void> fetchSubscription(
    ApiService apiService, {
    bool forceRefresh = false,
  }) async {
    // Don't fetch if already fetching
    if (_isFetching) return;

    // Don't fetch if data is recent (within 30 seconds) unless forced
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < Duration(seconds: 30)) {
      return;
    }

    _isFetching = true;
    setStateLoading(true);

    try {
      final subscription = await apiService.getCurrentSubscription();
      _subscription = subscription;
      _hasNoSubscription = subscription == null;
      _errorMessage = '';
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load subscription';
      if (_errorMessage == 'Failed to load subscription') {
        ApiService(baseUrl: AppUrls.appUrl).refreshToken();
      }
      debugPrint('Error fetching subscription: $e');
      notifyListeners();
    } finally {
      _isFetching = false;
      setStateLoading(false);
    }
  }

  void setStateLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> clearSubscription() async {
    _subscription = null;
    _hasNoSubscription = true;
    notifyListeners();
  }
}
