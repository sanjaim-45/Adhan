import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/ui/screens/subscription/device_request/step_content.dart';
import 'package:prayerunitesss/ui/screens/subscription/device_request/stepper_item.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:provider/provider.dart';

import '../../../../model/api/device_request/device_request_model.dart';
import '../../../../model/api/login/login_model.dart';
import '../../../../model/api/mosque/mosque_model.dart';
import '../../../../providers/device_request/device_request_provider.dart';
import '../../../../service/api/address/get_all/get_all_shipping_address.dart';
import '../../../../service/api/device_request/device_request_api_service.dart';
import '../../../../service/api/mosque/get_all_mosques.dart';
import '../../../../service/api/subscription/subscription_service.dart';
import '../../../../utils/font_mediaquery.dart';
import 'add_new_address.dart';
import 'dotted_line.dart';
import 'order_placed.dart';

class DeviceRequestScreen extends StatefulWidget {
  const DeviceRequestScreen({super.key});

  @override
  State<DeviceRequestScreen> createState() => _DeviceRequestScreenState();
}

class _DeviceRequestScreenState extends State<DeviceRequestScreen> {
  List<Mosque?> selectedMasjids = [null];
  List<SubscriptionPlan?> selectedPlans = [
    null,
  ]; // Changed to store plan objects
  int currentStep = 0;
  List<Map<String, dynamic>> savedAddresses = [];
  Map<String, dynamic>? selectedAddress;
  String? selectedPaymentMethod;
  List<Mosque> mosqueList = [];
  bool isLoading = true;
  String selectedPlan = 'Monthly';
  List<int> quantities = [1]; // Initialize with default quantity 1

  int? selectedPlanId;
  List<SubscriptionPlan> plans =
      []; // Changed to store list of SubscriptionPlan
  String errorMessage = '';
  void addDevice() {
    setState(() {
      selectedMasjids.add(null);
      selectedPlans.add(null);
      quantities.add(1); // Add default quantity for new device
    });
  }

  void removeDevice(int index) {
    setState(() {
      selectedMasjids.removeAt(index);
      selectedPlans.removeAt(index);
      quantities.removeAt(index);
    });
  }

  void updateMasjid(int index, Mosque? value) {
    setState(() {
      selectedMasjids[index] = value;
      selectedPlans[index] = null; // Reset plan when masjid changes
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMosques();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await SubscriptionService.getSubscriptionPlans();
      if (response['data'] != null) {
        setState(() {
          plans =
              (response['data'] as List)
                  .map((plan) => SubscriptionPlan.fromJson(plan))
                  .toList();
        });
      } else {
        setState(() {
          errorMessage =
              response['message'] ?? 'Failed to load subscription plans';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load subscription plans: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMosques() async {
    try {
      final mosqueService = MosqueService(
        apiService: ApiService(baseUrl: AppUrls.appUrl),
      );
      final response = await mosqueService.getAllMosques();
      setState(() {
        mosqueList = response.data; // Access the data property
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load mosques: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void updatePlan(int index, SubscriptionPlan? value) {
    setState(() {
      selectedPlans[index] = value;
    });
  }

  void nextStep() async {
    if (currentStep == 0) {
      // Check if ALL devices have both masjid and plan selected
      bool allDevicesComplete = selectedMasjids.asMap().entries.every(
        (entry) => entry.value != null && selectedPlans[entry.key] != null,
      );

      if (!allDevicesComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both masjid and plan for all devices'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check if at least one device is selected (redundant with above check, but safe)
      bool hasAtLeastOneDevice =
          selectedMasjids.any((m) => m != null) &&
          selectedPlans.any((p) => p != null);

      if (!hasAtLeastOneDevice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one device'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final provider = Provider.of<DeviceRequestProvider>(
        context,
        listen: false,
      );
      provider.clearRequests();

      for (int i = 0; i < selectedMasjids.length; i++) {
        provider.addDeviceRequest(
          selectedMasjids[i]!.mosqueId,
          selectedPlans[i]!.planId,
          quantities[i],
        );
      }

      setState(() {
        currentStep++;
      });
    } else if (currentStep == 1) {
      final provider = Provider.of<DeviceRequestProvider>(
        context,
        listen: false,
      );

      // First check if there are any addresses available
      final addresses =
          await ShippingAddressGetAllApiService(
            apiService: ApiService(baseUrl: AppUrls.appUrl),
          ).getShippingAddresses();

      if (addresses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one address before proceeding'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Then check if any address is selected (including the default one)
      if (provider.shippingAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an address'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        currentStep++;
      });
    }
    // Step 2: Payment
    else if (currentStep == 2) {
      if (selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final provider = Provider.of<DeviceRequestProvider>(
        context,
        listen: false,
      );
      provider.setPaymentMethod(selectedPaymentMethod!);

      // Prepare the request
      final request = DeviceRequest(
        devices:
            provider.deviceRequests
                .asMap()
                .entries
                .map(
                  (entry) => DeviceRequestItem(
                    quantity: provider.quantities[entry.key],
                    subscriptionPlanId: entry.value['planId'],
                    mosqueId: entry.value['masjidId'],
                  ),
                )
                .toList(),
        selectedShippingAddressId: provider.shippingAddressId!,
        paymentMethod: provider.paymentMethod!,
      );

      try {
        final service = DeviceRequestService(
          apiService: ApiService(baseUrl: AppUrls.appUrl),
        );
        await service.submitDeviceRequest(request);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OrderPlaced()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> _addNewAddress() async {
    final newAddress = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddNewAddressPage()));

    if (newAddress != null) {
      setState(() {
        savedAddresses.add(newAddress);
        selectedAddress = newAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentStep > 0) {
          setState(() {
            currentStep--;
          });
          return false; // Prevent default back behavior
        }
        return true; // Allow default back behavior (pop the screen)
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: AppBar(
                surfaceTintColor: Colors.white, // <--- NEW
                shadowColor: Colors.transparent,
                backgroundColor: Colors.white,
                elevation: 0,
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      if (currentStep > 0) {
                        previousStep(); // Go to previous step
                      } else {
                        Navigator.of(
                          context,
                        ).pop(); // Only pop if on first step
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 40,
                      height: 15,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(
                    'Device Request',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.black,
                      letterSpacing: -0.5,
                      fontSize: getDynamicFontSize(context, 0.05),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StepperItem(
                      label: 'Devices',
                      isActive: currentStep >= 0,
                      isCompleted: currentStep > 0,
                    ),
                  ),

                  DottedLine(isActive: currentStep > 0),
                  Expanded(
                    child: StepperItem(
                      label: 'Address',
                      isActive: currentStep >= 1,
                      isCompleted: currentStep > 1,
                    ),
                  ),
                  DottedLine(isActive: currentStep > 1),
                  Expanded(
                    child: StepperItem(
                      label: 'Checkout',
                      isActive: currentStep >= 2,
                      isCompleted: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StepContentWidget(
                  step: currentStep,
                  selectedMasjids: selectedMasjids,
                  selectedPlans: selectedPlans,
                  masjidList: mosqueList,
                  updateMasjid: updateMasjid,
                  updatePlan: updatePlan,
                  addDevice: addDevice,
                  selectedAddress: selectedAddress,
                  savedAddresses: savedAddresses,
                  addNewAddress: _addNewAddress,
                  plans: plans, // Add this line to pass the plans list
                  removeDevice: removeDevice,

                  selectedPaymentMethod: selectedPaymentMethod,
                  onPaymentMethodChanged: (String? value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                  onAddressSelected: (Map address) {
                    print("Address selected: $address");
                    Provider.of(
                      context,
                      listen: false,
                    ).setShippingAddressId(address['shippingAddressId'] as int);
                    setState(() {
                      selectedAddress = Map<String, dynamic>.from(
                        address,
                      ); // Explicit conversion
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentStep == 2 ? 'Place Order' : 'Continue',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
