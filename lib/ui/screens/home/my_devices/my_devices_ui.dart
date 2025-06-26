import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';

import '../../../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../../../model/api/mosque/mosque_model.dart';
import '../../../../service/api/customer/customer_service_api.dart';
import '../../../../service/api/customer_mosque_service/customer_mosque_map_service.dart';
import '../../../../service/api/mosque/get_all_mosques.dart';
import '../../../../service/api/mosque_change_request/mosque_change_request_api.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/font_mediaquery.dart';

class MyDevicesPage extends StatefulWidget {
  const MyDevicesPage({super.key});

  @override
  State<MyDevicesPage> createState() => _MyDevicesPageState();
}

class _MyDevicesPageState extends State<MyDevicesPage> {
  List<int> deviceIds = []; // This will be populated from API
  final List<String?> _selectedMosquesForDevices = [];
  int? _deviceIndexBeingEdited;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  List<Mosque> _filteredMosques = [];
  List<Mosque> _allMosques = [];
  bool _isLoading = true;
  String? _errorMessage;
  late MosqueService _mosqueService;
  late CustomerServices _customerService; // Add this
  late List<CustomerDevice> _allDevices = []; // Store all devices
  final List<int?> _selectedMosqueIdsForDevices =
      []; // Store mosque IDs instead of names
  late CustomerMosqueMapService _mosqueMapService;

  @override
  void initState() {
    super.initState();
    _mosqueService = MosqueService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    );
    _customerService = CustomerServices(baseUrl: AppUrls.appUrl); // Initialize
    _searchController.addListener(_filterMosques);
    _mosqueMapService = CustomerMosqueMapService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    ); // Add this

    _fetchData(); // Combined fetch method
  }

  Future<void> _assignDevices() async {
    try {
      // Get customer details to get customerId
      final customerResponse = await _customerService.getAllCustomerDetails();
      final customerId = customerResponse.data?.customerId;

      if (customerId == null) {
        throw Exception('Customer ID not found');
      }

      // Prepare the assignments list
      final List<Map<String, dynamic>> assignments = [];

      for (int i = 0; i < _allDevices.length; i++) {
        final mosqueId = _selectedMosqueIdsForDevices[i];

        // Only include devices that have a mosque selected and don't already have this mosque assigned
        if (mosqueId != null &&
            (_allDevices[i].mosque == null ||
                _allDevices[i].mosque!.mosqueId != mosqueId)) {
          assignments.add({
            'customerId': customerId,
            'deviceId': _allDevices[i].deviceId,
            'mosqueId': mosqueId,
          });
        }
      }

      if (assignments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to assign'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Call the API
      await _mosqueMapService.assignDevicesToMosques(assignments);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devices assigned successfully')),
      );

      // Refresh the data to reflect changes
      await _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign devices: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchData() async {
    try {
      // Fetch mosques
      final mosqueResponse = await _mosqueService.getAllMosques();

      // Fetch customer details to get devices
      final customerResponse = await _customerService.getAllCustomerDetails();

      // Extract all devices from all customers
      final allDevices = customerResponse.data?.devices ?? [];

      // Create device IDs list (using serialNumber as ID)
      setState(() {
        _allMosques = mosqueResponse.data;
        _filteredMosques = _allMosques;
        _allDevices = allDevices;
        deviceIds = allDevices.map((device) => device.deviceId).toList();

        // Initialize selected mosque IDs
        _selectedMosqueIdsForDevices.length = deviceIds.length;

        // Set default mosque selection based on device's mosqueId
        for (int i = 0; i < _allDevices.length; i++) {
          if (_allDevices[i].mosque != null) {
            _selectedMosqueIdsForDevices[i] = _allDevices[i].mosque!.mosqueId;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  String? _getMosqueNameById(int? mosqueId) {
    if (mosqueId == null) return null;
    final mosque = _allMosques.firstWhere(
      (m) => m.mosqueId == mosqueId,
      orElse:
          () => Mosque(
            customerCount: 0,
            mosqueId: 0,
            mosqueName: '',
            mosqueLocation: '',
            contactPersonName: '',
            contactNumber: '',
            streetName: '',
            area: '',
            city: '',
            governorate: '',
            pacinumber: '',
            status: false,
          ),
    );
    return mosque.mosqueId != 0 ? mosque.mosqueName : null;
  }

  void _filterMosques() {
    setState(() {
      _filteredMosques =
          _allMosques
              .where(
                (mosque) => mosque.mosqueName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  void _openMosqueSearch(int deviceIndex) {
    setState(() {
      _deviceIndexBeingEdited = deviceIndex;
      _showSearchBar = true;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectMosque(Mosque mosque) {
    setState(() {
      if (_deviceIndexBeingEdited != null) {
        _selectedMosqueIdsForDevices[_deviceIndexBeingEdited!] =
            mosque.mosqueId;
        _showSearchBar = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showAssignButton =
        _isLoading
            ? false
            : _selectedMosqueIdsForDevices.any((id) => id == null);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showSearchBar ? 140 : 80),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leadingWidth: 70,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_showSearchBar) {
                          setState(() {
                            _showSearchBar = false;
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.withAlpha(128),
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
                      _showSearchBar ? 'Select Mosque' : 'My Devices',
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
              if (_showSearchBar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: SingleChildScrollView(
                    // Wrapped with SingleChildScrollView
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for a mosque...',
                            prefixIcon: const Icon(Icons.search),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          autofocus: true,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child:
                    _isLoading // If loading, show progress indicator
                        ? const Center(child: CircularProgressIndicator())
                        : deviceIds
                            .isEmpty // If not loading and no devices
                        ? Center(
                          child: Text(
                            'No devices linked.',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                        // If not loading and devices exist, show the list
                        : ListView.builder(
                          itemCount: deviceIds.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            return DeviceTile(
                              deviceId: deviceIds[index].toString(),
                              selectedMosque: _getMosqueNameById(
                                _selectedMosqueIdsForDevices[index],
                              ),
                              onSelectMosque: () => _openMosqueSearch(index),
                              isSelected: _deviceIndexBeingEdited == index,
                              allMosques: _allMosques,
                            );
                          },
                        ),
              ),

              if (showAssignButton)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final mosqueName =
                            _deviceIndexBeingEdited != null
                                ? _getMosqueNameById(
                                  _selectedMosqueIdsForDevices[_deviceIndexBeingEdited!],
                                )
                                : '[Masjid Name]';

                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmMasjidAssignmentSheet(
                              mosqueName: mosqueName,
                              onConfirm: _assignDevices,
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Assign Now',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_showSearchBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _filteredMosques.isEmpty
                        ? const Center(child: Text('No mosques found'))
                        : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _filteredMosques.length,
                          itemBuilder: (context, index) {
                            final mosque = _filteredMosques[index];
                            return ListTile(
                              title: Text(mosque.mosqueName),
                              subtitle:
                                  mosque.mosqueLocation.isNotEmpty
                                      ? Text(mosque.mosqueLocation)
                                      : null,
                              onTap:
                                  () => _selectMosque(
                                    mosque,
                                  ), // Pass the whole mosque object
                            );
                          },
                        ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConfirmMasjidAssignmentSheet extends StatelessWidget {
  final String? mosqueName;
  final Future<void> Function()? onConfirm;

  const ConfirmMasjidAssignmentSheet({
    super.key,
    this.mosqueName,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'Confirm Masjid Assignment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to connect this device to ${mosqueName ?? '[Masjid Name]'}? You can do this only once. Future changes require admin approval',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (onConfirm != null) {
                      try {
                        await onConfirm!();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Device assigned successfully'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to assign device: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }
}

class DeviceAlreadyAssignedSheet extends StatefulWidget {
  final String? mosqueName;
  final List<Mosque> mosques;
  final int deviceId;
  final int currentMosqueId;

  const DeviceAlreadyAssignedSheet({
    super.key,
    this.mosqueName,
    required this.mosques,
    required this.deviceId,
    required this.currentMosqueId,
  });

  @override
  State<DeviceAlreadyAssignedSheet> createState() =>
      _DeviceAlreadyAssignedSheetState();
}

class _DeviceAlreadyAssignedSheetState
    extends State<DeviceAlreadyAssignedSheet> {
  Mosque? _selectedMosque;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  late MosqueChangeRequestService _requestService;
  String? _mosqueError; // To store mosque validation error
  String? _reasonError; // To store reason validation error

  @override
  void initState() {
    super.initState();
    _requestService = MosqueChangeRequestService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    );
    if (widget.mosqueName != null && widget.mosques.isNotEmpty) {
      _selectedMosque = widget.mosques.firstWhere(
        (m) => m.mosqueName == widget.mosqueName,
        orElse: () => widget.mosques.first,
      );
    } else if (widget.mosques.isNotEmpty) {
      _selectedMosque = widget.mosques.first;
    }
  }

  Future<void> _submitChangeRequest() async {
    // Reset errors
    setState(() {
      _mosqueError = null;
      _reasonError = null;
    });

    // Mosque validation - must be different from current
    if (_selectedMosque == null ||
        _selectedMosque!.mosqueId == widget.currentMosqueId) {
      setState(() {
        _mosqueError = 'Please select a different mosque';
      });
      return;
    }

    // Reason validation - can be empty but we'll pass empty string
    // No validation needed as per requirements

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _requestService.submitMosqueChangeRequest(
        deviceId: widget.deviceId,
        currentMosqueId: widget.currentMosqueId,
        requestedMosqueId: _selectedMosque!.mosqueId,
        reason: _reasonController.text, // This can be empty
      );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request submitted to change to ${_selectedMosque!.mosqueName}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Device Already Assigned',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'This device is already connected to ${widget.mosqueName ?? '[Masjid Name]'}. To make changes, select the mosque below and raise a request to admin:',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Mosque Dropdown with error message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Mosque>(
                  value: _selectedMosque,
                  decoration: InputDecoration(
                    labelText: 'Select New Mosque',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items:
                      widget.mosques.map((Mosque mosque) {
                        return DropdownMenuItem<Mosque>(
                          value: mosque,
                          child: Text(
                            mosque.mosqueName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged: (Mosque? newValue) {
                    setState(() {
                      _selectedMosque = newValue;
                      // Clear error when user selects something
                      if (newValue != null &&
                          newValue.mosqueId != widget.currentMosqueId) {
                        _mosqueError = null;
                      }
                    });
                  },
                ),
                if (_mosqueError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      _mosqueError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Reason TextField
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason for change',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF2E7D32)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    // No error text since reason can be empty
                  ),
                ),

                // No error display for reason as it's optional
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitChangeRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Submit Request to Admin',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceTile extends StatelessWidget {
  final String deviceId;
  final String? selectedMosque;
  final VoidCallback onSelectMosque;
  final bool isSelected;
  final List<Mosque> allMosques;

  const DeviceTile({
    super.key,
    required this.deviceId,
    this.selectedMosque,
    required this.onSelectMosque,
    required this.isSelected,
    required this.allMosques,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Image.asset(
                "assets/images/active_devices.png",
                height: 21,
                width: 21,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device ID', style: TextStyle(color: Colors.grey[700])),
                  Text(
                    deviceId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              // Wrap the mosque selection widget in IgnorePointer when mosque is selected
              IgnorePointer(
                ignoring: selectedMosque != null,
                child: GestureDetector(
                  onTap: onSelectMosque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            selectedMosque ?? 'Select Mosque',
                            style: TextStyle(
                              color:
                                  selectedMosque == null
                                      ? const Color(0xFF2E7D32)
                                      : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedMosque == null)
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF2E7D32),
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selectedMosque != null) const SizedBox(width: 5),
              if (selectedMosque != null)
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // This is important
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(
                                  context,
                                ).viewInsets.bottom, // Account for keyboard
                          ),
                          child: DeviceAlreadyAssignedSheet(
                            mosqueName: selectedMosque,
                            mosques: allMosques,
                            deviceId: int.tryParse(deviceId) ?? 0,
                            currentMosqueId:
                                allMosques
                                    .firstWhere(
                                      (m) => m.mosqueName == selectedMosque,
                                      orElse:
                                          () => Mosque(
                                            customerCount: 0,
                                            mosqueId: 0,
                                            mosqueName: '',
                                            mosqueLocation: '',
                                            contactPersonName: '',
                                            contactNumber: '',
                                            streetName: '',
                                            area: '',
                                            city: '',
                                            governorate: '',
                                            pacinumber: '',
                                            status: false,
                                          ),
                                    )
                                    .mosqueId,
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.mode_edit_outline_outlined),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
