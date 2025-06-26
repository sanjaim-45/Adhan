import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:prayerunitesss/model/api/devices/my_devices_model.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../../../model/api/address/shipping_address_create_model.dart';
import '../../../../../service/api/address/get_all/get_all_shipping_address.dart';
import '../../../../../service/api/devices_list/devices_list_api.dart';
import '../../../../../service/api/request_return/request_return_api.dart';
import '../../../../../service/api/tokens/token_service.dart';
import '../../../../../utils/font_mediaquery.dart';
import '../add_delivery_addresss_ui.dart';
import '../delivery_address_page.dart';
import 'request_submitted.dart';

class ReturnRequestFormPage extends StatefulWidget {
  const ReturnRequestFormPage({super.key});

  @override
  State<ReturnRequestFormPage> createState() => _ReturnRequestFormPageState();
}

class _ReturnRequestFormPageState extends State<ReturnRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedReason;
  DeviceDropdown? selectedDevice;
  bool useSavedAddress = false;
  List<XFile> _selectedImages = [];
  List<DeviceDropdown> devices = [];
  bool isLoading = false;
  List<ShippingAddress> shippingAddresses = [];
  ShippingAddress? selectedShippingAddress;
  bool isLoadingAddresses = false;
  late ShippingAddressDeleteApiService _deleteService;
  String? addressErrorMessage;
  final TextEditingController _reasonDetailsController =
      TextEditingController();
  final List<String> reasons = [
    "Device not working",
    "Received wrong item",
    "Damaged on arrival",
    "Other",
  ];

  Future<void> _loadDevices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final deviceService = DeviceService(
        apiService: ApiService(baseUrl: AppUrls.appUrl),
      );
      final deviceList = await deviceService.getMyDevices();

      setState(() {
        devices = deviceList;
        if (devices.isNotEmpty) {
          selectedDevice = devices.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load devices: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _deleteService = ShippingAddressDeleteApiService(
      baseUrl: AppUrls.appUrl,
      client: http.Client(),
    );
    _loadDevices();
    _loadShippingAddresses();
  }

  Future<void> _loadShippingAddresses() async {
    setState(() {
      isLoadingAddresses = true;
      addressErrorMessage = null;
    });

    try {
      final accessToken = await TokenService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      final service = ShippingAddressGetAllApiService(
        apiService: ApiService(baseUrl: AppUrls.appUrl),
      );

      final addresses = await service.getShippingAddresses();

      setState(() {
        shippingAddresses = addresses;
        if (addresses.isNotEmpty) {
          selectedShippingAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        addressErrorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoadingAddresses = false;
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog(ShippingAddress address) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteAddress(address.shippingAddressId);
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

  Future<void> _deleteAddress(int addressId) async {
    try {
      setState(() {
        isLoadingAddresses = true;
      });

      final success = await _deleteService.deleteShippingAddress(addressId);

      if (success) {
        await _loadShippingAddresses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            behavior: SnackBarBehavior.floating,

            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingAddresses = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,

            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _navigateToEditAddress(ShippingAddress? address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDeliveryAddressPage(existingAddress: address),
      ),
    ).then((_) {
      _loadShippingAddresses();
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  @override
  void dispose() {
    _reasonDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              surfaceTintColor: Colors.white,
              foregroundColor: Colors.white,
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 70,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: EdgeInsets.all(10),
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
                  'Return Request Forms',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Select Device",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DeviceDropdown>(
                icon: const Icon(Icons.keyboard_arrow_down_sharp),
                iconEnabledColor: const Color(0xFF2E7D32),
                dropdownColor: Colors.white,
                hint: const Text("Select a device"),
                style: TextStyle(color: Colors.black),
                value: selectedDevice,
                items:
                    devices.map((device) {
                      return DropdownMenuItem<DeviceDropdown>(
                        value: device,
                        child: Text(device.deviceName),
                      );
                    }).toList(),
                onChanged: (DeviceDropdown? value) {
                  setState(() {
                    selectedDevice = value;
                  });
                },
                menuMaxHeight: 200,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a device';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Reason for Return",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                icon: const Icon(Icons.keyboard_arrow_down_sharp),
                iconEnabledColor: const Color(0xFF2E7D32),
                dropdownColor: Colors.white,
                hint: const Text("e.g. Device not working"),
                style: TextStyle(color: Colors.black),
                value: selectedReason,
                items:
                    reasons.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
                menuMaxHeight: 200,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Reason Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Color(0xFFA1A1A1)),
                  hintText:
                      'e.g., "Speaker has a crack and does not power on."',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Upload Photos",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImages,
                child: const DottedBorderWidget(),
              ),
              const SizedBox(height: 12),
              if (_selectedImages.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    return UploadedFileWidget(
                      fileName: path.basename(image.path),
                      fileSize:
                          "${(File(image.path).lengthSync() / 1024).toStringAsFixed(2)} KB",
                      imagePath: image.path,
                      onDelete: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
                      onView: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [Image.file(File(image.path))],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text("Use default delivery address"),
                value: useSavedAddress,
                onChanged:
                    shippingAddresses.isEmpty
                        ? null
                        : (val) {
                          setState(() {
                            useSavedAddress = val!;
                            if (useSavedAddress) {
                              try {
                                selectedShippingAddress = shippingAddresses
                                    .firstWhere(
                                      (a) => a.isDefault,
                                      orElse: () => shippingAddresses.first,
                                    );
                              } catch (e) {
                                selectedShippingAddress = null;
                              }
                            } else {
                              selectedShippingAddress = null;
                            }
                          });
                        },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (!useSavedAddress) ...[
                const SizedBox(height: 16),
                const Text(
                  "Select Delivery Address",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (isLoadingAddresses)
                  const Center(child: CircularProgressIndicator())
                else if (addressErrorMessage != null)
                  Text(
                    addressErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                else if (shippingAddresses.isEmpty)
                  Column(
                    children: [
                      const Text(
                        "No addresses found. Please add a delivery address.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddDeliveryAddressPage(),
                              ),
                            ).then((_) {
                              _loadShippingAddresses();
                            });
                          },
                          child: Text(
                            'Add New Address',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children:
                        shippingAddresses.map((address) {
                          return AddressTile(
                            isSelected:
                                selectedShippingAddress?.shippingAddressId ==
                                address.shippingAddressId,
                            address: address,
                            onTap: () {
                              setState(() {
                                selectedShippingAddress = address;
                              });
                            },
                            onEdit: () {
                              _navigateToEditAddress(address);
                            },
                            onDelete: () {
                              _showDeleteConfirmationDialog(address);
                            },
                          );
                        }).toList(),
                  ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        selectedDevice != null) {
                      if (selectedReason == null || selectedReason!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a reason'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final accessToken = await TokenService.getAccessToken();
                      if (accessToken == null || accessToken.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Authentication required'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      String? shippingAddressId;
                      if (useSavedAddress) {
                        if (shippingAddresses.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No saved addresses available'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        try {
                          shippingAddressId =
                              shippingAddresses
                                  .firstWhere((a) => a.isDefault)
                                  .shippingAddressId
                                  .toString();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No default address found'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                      } else {
                        if (shippingAddresses.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add a delivery address'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        if (selectedShippingAddress == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a shipping address'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        shippingAddressId =
                            selectedShippingAddress!.shippingAddressId
                                .toString();
                      }

                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final service = ReturnRequestApiService(
                          baseUrl: AppUrls.appUrl,
                          client: http.Client(),
                        );

                        final description =
                            '$selectedReason\n\n${_reasonDetailsController.text}';

                        final success = await service.submitReturnRequest(
                          deviceId: selectedDevice!.deviceId.toString(),
                          reason: selectedReason!,
                          description: description,
                          shippingAddressId: shippingAddressId!,
                          images: _selectedImages,
                          accessToken: accessToken,
                        );

                        if (success) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RequestSubmitted(),
                            ),
                            (route) => route.isFirst,
                          );
                        }
                      } catch (e) {
                        String errorMessage = 'Failed to submit request';
                        if (e is http.Response) {
                          try {
                            final Map<String, dynamic> errorJson = json.decode(
                              e.body,
                            );
                            errorMessage = errorJson['message'] ?? errorMessage;
                          } catch (_) {
                            errorMessage = e.body;
                          }
                        } else if (e is Exception) {
                          final messageMatch = RegExp(
                            r'\{.*\}',
                          ).firstMatch(e.toString());
                          if (messageMatch != null) {
                            try {
                              final errorJson = json.decode(
                                messageMatch.group(0)!,
                              );
                              errorMessage =
                                  errorJson['message'] ?? errorMessage;
                            } catch (_) {}
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } else if (selectedDevice == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a device'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text(
                            'Submit Request',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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

class DottedBorderWidget extends StatelessWidget {
  const DottedBorderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RectDottedBorderOptions(
        dashPattern: [10, 5],
        strokeWidth: 1,
        color: Color(0xFFEBEBEB),
        padding: EdgeInsets.all(16),
      ),
      child: Container(
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                backgroundColor: Color(0xFFF5F5F5),
                child: Icon(
                  Icons.upload_file_outlined,
                  size: 28,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Click to Upload",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text("(Max. File size: 5 MB)", style: TextStyle()),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadedFileWidget extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final String imagePath;

  const UploadedFileWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.onDelete,
    required this.onView,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Image.file(
            File(imagePath),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fileName,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onDelete,
                  child: Image.asset(
                    'assets/images/trash.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fileSize, style: TextStyle(color: Color(0xFF989692))),
            InkWell(
              onTap: onView,
              child: const Text(
                "Click to View",
                style: TextStyle(
                  color: Color(0xFFA020F0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
