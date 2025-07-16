import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../../model/api/address/shipping_address_create_model.dart';
import '../../../../service/api/address/get_all/get_all_shipping_address.dart';
import '../../../../service/api/templete_api/api_service.dart';
import '../../../../service/api/tokens/token_service.dart';
import '../../../../utils/custom_appbar.dart';
import 'add_delivery_addresss_ui.dart';

// Add Service for delete API
class ShippingAddressDeleteApiService {
  final String baseUrl;
  final http.Client client;

  ShippingAddressDeleteApiService({
    required this.baseUrl,
    required this.client,
  });

  Future<bool> deleteShippingAddress(int addressId) async {
    // Get the stored access token
    final accessToken = await TokenService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No access token found');
    }
    final url = Uri.parse(
      '$baseUrl/api/CustomerShippingAddress/DeleteShippingAddress?id=$addressId',
    );
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 206) {
      return true;
    } else {
      throw Exception(
        'Failed to delete address. Status code: ${response.statusCode}',
      );
    }
  }
}

class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({super.key});

  @override
  _DeliveryAddressPageState createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  late ShippingAddressGetAllApiService _shippingAddressApiService;
  late ShippingAddressDeleteApiService _deleteService;
  List<ShippingAddress> _shippingAddresses = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedAddressIndex;

  @override
  void initState() {
    super.initState();
    _shippingAddressApiService = ShippingAddressGetAllApiService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    );
    _deleteService = ShippingAddressDeleteApiService(
      baseUrl: AppUrls.appUrl,
      client: http.Client(),
    );
    _loadShippingAddresses();
  }

  Future<void> _loadShippingAddresses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final addresses = await _shippingAddressApiService.getShippingAddresses();
      if (!mounted) return;
      setState(() {
        _shippingAddresses = addresses;
        _selectedAddressIndex = addresses.indexWhere((a) => a.isDefault);
        if (_selectedAddressIndex == -1 && addresses.isNotEmpty) {
          _selectedAddressIndex = 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Add a dispose method to cancel any pending operations
  // and prevent memory leaks.
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
                Icon(Icons.delete_outline, size: 80, color: Colors.red[400]),
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
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final success = await _deleteService.deleteShippingAddress(addressId);

      if (success) {
        await _loadShippingAddresses();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            behavior: SnackBarBehavior.floating,

            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Delivery Address',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildBodyContent(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Add New Address',
            style: GoogleFonts.beVietnamPro(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddDeliveryAddressPage(
                      existingAddress: null,
                      isFirstAddress: _shippingAddresses.isEmpty,
                    ),
              ),
            ).then((_) {
              _loadShippingAddresses();
            });
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading addresses',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadShippingAddresses,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_shippingAddresses.isEmpty) {
      return Center(
        child: Text(
          'No shipping addresses found. Add a new one!',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _shippingAddresses.length,
      itemBuilder: (context, index) {
        final address = _shippingAddresses[index];
        return AddressTile(
          isSelected: _selectedAddressIndex == index,
          address: address,
          onTap: () {
            setState(() {
              _selectedAddressIndex = index;
            });
          },
          onEdit: () {
            _navigateToEditAddress(address);
          },
          onDelete: () {
            if (address.isDefault) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'You cannot delete the default address. Please set another address as default first.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              _showDeleteConfirmationDialog(address);
            }
          },
        );
      },
    );
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
}

class AddressTile extends StatelessWidget {
  final bool isSelected;
  final ShippingAddress address;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressTile({
    Key? key,
    required this.isSelected,
    required this.address,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizewidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          // color: Colors.white,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Remove Radio button as per requirement
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              address.fullName.length > 20
                                  ? '${address.fullName.substring(0, 20)}...'
                                  : address.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: sizewidth * 0.0356,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2E7D32).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: sizewidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 20,
                              color:
                                  address.isDefault
                                      ? Colors.grey
                                      : Colors.red[300],
                            ),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    address.address,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: sizewidth * 0.0356,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phoneNumber,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: sizewidth * 0.0356,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
