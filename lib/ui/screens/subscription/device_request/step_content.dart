import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../model/api/address/shipping_address_create_model.dart';
import '../../../../model/api/login/login_model.dart';
import '../../../../model/api/mosque/mosque_model.dart';
import '../../../../providers/device_request/device_request_provider.dart';
import '../../../../service/api/address/get_all/get_all_shipping_address.dart';
import '../../../../service/api/templete_api/api_service.dart';
import '../../settings/delivery_address/add_delivery_addresss_ui.dart';
import '../../settings/delivery_address/delivery_address_page.dart';
import 'mosque_tiles.dart';

class StepContentWidget extends StatelessWidget {
  final int step;
  final List<Mosque?> selectedMasjids;
  final List<SubscriptionPlan?> selectedPlans;
  final List<Mosque> masjidList;
  final Function(int, Mosque?) updateMasjid;
  final Function(int) removeDevice; // Add this line
  final Function(int, SubscriptionPlan?) updatePlan;
  final VoidCallback addDevice;
  final Map<String, dynamic>? selectedAddress;
  final List<Map<String, dynamic>> savedAddresses;
  final Future<void> Function() addNewAddress;
  final String? selectedPaymentMethod;
  final Function(String?) onPaymentMethodChanged;
  final Function(Map<String, dynamic>) onAddressSelected;
  List<SubscriptionPlan> plans =
      []; // Changed to store list of SubscriptionPlan

  StepContentWidget({
    super.key,
    required this.step,
    required this.selectedMasjids,
    required this.selectedPlans,
    required this.masjidList,
    required this.updateMasjid,
    required this.removeDevice, // Add this to the constructor
    required this.updatePlan,
    required this.addDevice,
    this.selectedAddress,
    required this.savedAddresses,
    required this.addNewAddress,
    this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.onAddressSelected,
    required this.plans, // Add this to the constructor
  });
  String _formattedDate() {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 3));
    return '${deliveryDate.day.toString().padLeft(2, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Speaker Devices',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...List.generate(selectedMasjids.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Device ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                              fontSize: 16,
                            ),
                          ),
                          if (selectedMasjids.length >
                              1) // Show delete icon only if there's more than one device
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeDevice(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Masjid',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<Mosque>(
                          dropdownColor: Colors.white,
                          hint: const Text('Select Masjid'),
                          value: selectedMasjids[index],
                          items:
                              masjidList.map((masjid) {
                                return DropdownMenuItem(
                                  value: masjid,
                                  child: Text(masjid.mosqueName),
                                );
                              }).toList(),
                          onChanged: (value) => updateMasjid(index, value),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (selectedMasjids[index] != null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Plan',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<SubscriptionPlan>(
                            dropdownColor: Colors.white,
                            hint: const Text('Select Plan'),
                            value: selectedPlans[index],
                            items:
                                plans.map((plan) {
                                  return DropdownMenuItem(
                                    value: plan,
                                    child: Text(plan.planName),
                                  );
                                }).toList(),
                            onChanged: (value) => updatePlan(index, value),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () {
                if (selectedMasjids.isEmpty ||
                    (selectedMasjids.last != null &&
                        selectedPlans.last != null)) {
                  addDevice();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select Masjid and Plan for the previous device before adding a new one.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF2E7D32)),
                  SizedBox(width: 4),
                  Text(
                    'Add Another Device',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Address',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Consumer<DeviceRequestProvider>(
              builder: (context, provider, child) {
                return FutureBuilder<List<ShippingAddress>>(
                  future:
                      ShippingAddressGetAllApiService(
                        apiService: ApiService(baseUrl: AppUrls.appUrl),
                      ).getShippingAddresses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 200,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // If no addresses and no address is selected, set isSelected to true for the MosqueTiles
                      // This ensures the radio button is active when adding the first address.
                      if (provider.shippingAddressId == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Since there's no address ID to set, we can't call setShippingAddressId.
                          // The UI will handle showing "No shipping addresses found" or similar.
                          // However, we need to ensure that when a new address is added,
                          // it becomes selected by default. This logic is handled after adding a new address.
                        });
                      }
                      return const Text(
                        'No shipping addresses found',
                      ); // Keep this line to show the message
                    }

                    List<ShippingAddress> addresses = snapshot.data!;
                    final deleteService = ShippingAddressDeleteApiService(
                      baseUrl: AppUrls.appUrl,
                      client: http.Client(),
                    );

                    // If a new address was just added and it's the only one, select it.
                    if (addresses.length == 1 &&
                        provider.shippingAddressId == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setShippingAddressId(
                          addresses.first.shippingAddressId,
                        );
                        onAddressSelected({
                          'shippingAddressId':
                              addresses.first.shippingAddressId,
                          'fullName': addresses.first.fullName,
                          'address': addresses.first.address,
                          'phoneNumber': addresses.first.phoneNumber,
                          'email': addresses.first.email,
                          'isDefault': addresses.first.isDefault,
                        });
                      });
                    }

                    // Sort addresses: default first, then by some other criteria (e.g., creation date)
                    addresses.sort((a, b) {
                      if (a.isDefault && !b.isDefault) return -1;
                      if (!a.isDefault && b.isDefault) return 1;
                      return 0; // Maintain original order if both are default or non-default
                    });

                    // If no address is selected, and there are addresses, select the first (potentially default) one.
                    if (provider.shippingAddressId == null &&
                        addresses.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setShippingAddressId(
                          addresses.first.shippingAddressId,
                        );
                        onAddressSelected({
                          'shippingAddressId':
                              addresses.first.shippingAddressId,
                          'fullName': addresses.first.fullName,
                          'address': addresses.first.address,
                          'phoneNumber': addresses.first.phoneNumber,
                          'email': addresses.first.email,
                          'isDefault': addresses.first.isDefault,
                        });
                      });
                    }

                    return Column(
                      children:
                          addresses.map((address) {
                            final isSelected =
                                provider.shippingAddressId ==
                                address.shippingAddressId;

                            return GestureDetector(
                              onTap: () {
                                provider.setShippingAddressId(
                                  address.shippingAddressId,
                                );
                                onAddressSelected({
                                  'shippingAddressId':
                                      address.shippingAddressId,
                                  'fullName': address.fullName,
                                  'address': address.address,
                                  'phoneNumber': address.phoneNumber,
                                  'email': address.email,
                                  'isDefault': address.isDefault,
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: address.isDefault ? 10.0 : 0,
                                      ),
                                      child: MosqueTiles(
                                        isSelected: isSelected,
                                        mosqueName: address.address ?? '',
                                        email: address.email ?? '',
                                        onTap: () {
                                          provider.setShippingAddressId(
                                            address.shippingAddressId,
                                          );
                                          onAddressSelected({
                                            'shippingAddressId':
                                                address.shippingAddressId,
                                            'fullName': address.fullName,
                                            'address': address.address,
                                            'phoneNumber': address.phoneNumber,
                                            'email': address.email,
                                            'isDefault': address.isDefault,
                                          });
                                        },
                                        mobileNumber: address.phoneNumber ?? '',
                                        name: address.fullName ?? '',
                                        isDefault: address.isDefault,
                                      ),
                                    ),

                                    Positioned(
                                      top: -8,
                                      right: 0,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          AddDeliveryAddressPage(
                                                            existingAddress:
                                                                address,
                                                          ),
                                                ),
                                              );
                                              provider.refreshAddresses();
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red[300],
                                            ),
                                            onPressed: () async {
                                              await showDeleteAddressDialog(
                                                context: context,
                                                onDeleteConfirmed: () async {
                                                  try {
                                                    final success = await deleteService
                                                        .deleteShippingAddress(
                                                          address
                                                              .shippingAddressId,
                                                        );
                                                    if (success) {
                                                      provider
                                                          .refreshAddresses();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Address deleted successfully',
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Delete failed: ${e.toString()}',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  },
                );
              },
            ),

            // Rest of your existing case 1 code...
            GestureDetector(
              onTap: () async {
                await addNewAddress();
                Provider.of<DeviceRequestProvider>(
                  context,
                  listen: false,
                ).refreshAddresses();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'Add New Address',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Estimated Delivery Date',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    const TextSpan(
                      text: 'Delivered by ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: _formattedDate(),
                      style: const TextStyle(color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Device Price Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...selectedPlans
                          .asMap()
                          .entries
                          .where((entry) => entry.value != null)
                          .map((planEntry) {
                            final masjid = selectedMasjids[planEntry.key];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Device ${planEntry.key + 1} (${planEntry.value!.planName})',
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      Text(
                                        '${planEntry.value!.price.toStringAsFixed(2)} ${planEntry.value!.currency}',
                                      ),
                                    ],
                                  ),
                                  if (masjid != null) const SizedBox(height: 2),
                                  if (masjid != null)
                                    Text(
                                      masjid.mosqueName ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          })
                          .toList(),

                      const Divider(
                        height: 20,
                        thickness: 1,
                        color: Color(0xFFDBDBDB),
                      ),
                      // Total calculation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${selectedPlans.asMap().entries.where((entry) => entry.value != null).fold<double>(0.0, (sum, planEntry) {
                              return sum + (planEntry.value?.price ?? 0.0);
                            }).toStringAsFixed(2)} KWD',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Address',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Consumer<DeviceRequestProvider>(
              builder: (context, provider, child) {
                return FutureBuilder<List<ShippingAddress>>(
                  future:
                      ShippingAddressGetAllApiService(
                        apiService: ApiService(baseUrl: AppUrls.appUrl),
                      ).getShippingAddresses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 200,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No shipping addresses found');
                    }

                    final addresses = snapshot.data!;
                    final defaultAddress = addresses.firstWhere(
                      (address) => address.isDefault,
                      orElse: () => addresses.first,
                    );

                    // Initialize with default address if nothing is selected
                    if (provider.shippingAddressId == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setShippingAddressId(
                          defaultAddress.shippingAddressId,
                        );
                        onAddressSelected({
                          'shippingAddressId': defaultAddress.shippingAddressId,
                          'fullName': defaultAddress.fullName,
                          'address': defaultAddress.address,
                          'phoneNumber': defaultAddress.phoneNumber,
                          'email': defaultAddress.email,
                          'isDefault': defaultAddress.isDefault,
                        });
                      });
                    }

                    // Find the currently selected address
                    final selectedAddress = addresses.firstWhere(
                      (address) =>
                          address.shippingAddressId ==
                          provider.shippingAddressId,
                      orElse: () => defaultAddress,
                    );

                    return Column(
                      children: [
                        // Selected address (shown at the top)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              MosqueTiles(
                                isSelected: true,
                                mosqueName: selectedAddress.address ?? '',
                                email: selectedAddress.email ?? '',
                                onTap: () {},
                                mobileNumber: selectedAddress.phoneNumber ?? '',
                                name: selectedAddress.fullName ?? '',
                                isDefault: selectedAddress.isDefault,
                              ),
                              // if (selectedAddress.isDefault)
                              //   Positioned(
                              //     top: 0,
                              //     right: 0,
                              //     child: Container(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 6,
                              //         vertical: 2,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color: const Color(
                              //           0xFF2E7D32,
                              //         ).withOpacity(0.1),
                              //         borderRadius: BorderRadius.circular(4),
                              //       ),
                              //       child: const Text(
                              //         'Default',
                              //         style: TextStyle(
                              //           color: Color(0xFF2E7D32),
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),

                        // // Other addresses
                        // ...addresses
                        //     .where(
                        //       (address) =>
                        //           address.shippingAddressId !=
                        //           selectedAddress.shippingAddressId,
                        //     )
                        //     .map((address) {
                        //       return GestureDetector(
                        //         onTap: () {
                        //           provider.setShippingAddressId(
                        //             address.shippingAddressId,
                        //           );
                        //           onAddressSelected({
                        //             'shippingAddressId':
                        //                 address.shippingAddressId,
                        //             'fullName': address.fullName,
                        //             'address': address.address,
                        //             'phoneNumber': address.phoneNumber,
                        //             'email': address.email,
                        //             'isDefault': address.isDefault,
                        //           });
                        //         },
                        //         child: Container(
                        //           padding: const EdgeInsets.all(16),
                        //           margin: const EdgeInsets.only(bottom: 8),
                        //           decoration: BoxDecoration(
                        //             color: Colors.white,
                        //             borderRadius: BorderRadius.circular(12),
                        //             border: Border.all(
                        //               color: Colors.grey.shade300,
                        //               width: 1.5,
                        //             ),
                        //           ),
                        //           child: MosqueTiles(
                        //             isSelected: false,
                        //             mosqueName: address.address ?? '',
                        //             email: address.email ?? '',
                        //             onTap: () {
                        //               provider.setShippingAddressId(
                        //                 address.shippingAddressId,
                        //               );
                        //               onAddressSelected({
                        //                 'shippingAddressId':
                        //                     address.shippingAddressId,
                        //                 'fullName': address.fullName,
                        //                 'address': address.address,
                        //                 'phoneNumber': address.phoneNumber,
                        //                 'email': address.email,
                        //                 'isDefault': address.isDefault,
                        //               });
                        //             },
                        //             mobileNumber: address.phoneNumber ?? '',
                        //             name: address.fullName ?? '',
                        //           ),
                        //         ),
                        //       );
                        //     })
                        //     .toList(),
                      ],
                    );
                  },
                );
              },
            ),

            // Rest of your case 2 code remains the same...
            const SizedBox(height: 10),
            const Text(
              'Estimated Delivery Date',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    const TextSpan(
                      text: 'Delivered by ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: _formattedDate(),
                      style: const TextStyle(color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ),
            ),
            if (selectedMasjids.any((masjid) => masjid != null))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Device Price Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(selectedMasjids.length, (index) {
                          final masjid = selectedMasjids[index];
                          final plan = selectedPlans[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Device ${index + 1}${plan?.planName != null ? ' (${plan!.planName})' : ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    Text(
                                      '${plan?.price?.toStringAsFixed(2) ?? '0.00'} ${plan?.currency ?? 'KWD'}',
                                    ),
                                  ],
                                ),
                                if (masjid != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    masjid.mosqueName ?? '',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),

                        const Divider(
                          height: 20,
                          thickness: 1,
                          color: Color(0xFFDBDBDB),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${selectedPlans.fold<double>(0.0, (sum, plan) => sum + (plan?.price ?? 0.0)).toStringAsFixed(2)} KWD',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text('KNET (Online Payment)'),
                    value: 'KNET',
                    groupValue: selectedPaymentMethod,
                    onChanged: onPaymentMethodChanged,
                    activeColor: const Color(0xFF2E7D32),
                  ),
                  RadioListTile<String>(
                    title: const Text('Offline Payment'),
                    value: 'Offline',
                    groupValue: selectedPaymentMethod,
                    onChanged: onPaymentMethodChanged,
                    activeColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      default:
        return Container();
    }
  }
}

Future<void> showDeleteAddressDialog({
  required BuildContext context,
  required VoidCallback onDeleteConfirmed,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Icon(Icons.delete_outline, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Delete Address?',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to delete this shipping address? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 130,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDeleteConfirmed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Yes, Delete',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
