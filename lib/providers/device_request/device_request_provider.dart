import 'package:flutter/foundation.dart';

class DeviceRequestProvider with ChangeNotifier {
  List<Map<String, dynamic>> _deviceRequests = [];
  int? _shippingAddressId;
  String? _paymentMethod; // Add this
  List<int> _quantities = []; // Add this line
  List<int> get quantities => _quantities;

  List<Map<String, dynamic>> get deviceRequests => _deviceRequests;
  int? get shippingAddressId => _shippingAddressId;
  String? get paymentMethod => _paymentMethod; // Add this getter

  void addDeviceRequest(int masjidId, int planId, [int quantity = 1]) {
    _deviceRequests.add({'masjidId': masjidId, 'planId': planId});
    _quantities.add(quantity); // Add quantity
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _quantities.length) {
      _quantities[index] = quantity;
      notifyListeners();
    }
  }

  void setShippingAddressId(int addressId) {
    _shippingAddressId = addressId;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    // New method
    _paymentMethod = method;
    notifyListeners();
  }

  void refreshAddresses() {
    notifyListeners();
  }

  void clearRequests() {
    _deviceRequests.clear();
    _shippingAddressId = null;
    _paymentMethod = null; // Clear this as well
    notifyListeners();
  }
}
