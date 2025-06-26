// import 'package:flutter/material.dart';
//
// class BestSellingProductsUi extends StatefulWidget {
//   const BestSellingProductsUi({super.key});
//
//   @override
//   State<BestSellingProductsUi> createState() => _BestSellingProductsUiState();
// }
//
// class _BestSellingProductsUiState extends State<BestSellingProductsUi> {
//   late Future<BestSellingResponse> _bestSellingFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     final apiService = ReportApiService(baseUrl: AppUrl.baseUrl);
//     _bestSellingFuture = apiService.getBestSellingProducts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FF),
//       appBar: AppBar(
//         elevation: 0,
//         titleSpacing: 16,
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF8285D4), Color(0xFF4C46D7)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//         ),
//         title: Row(
//           children: [
//             GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: CircleAvatar(
//                 radius: 18,
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 15,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Best Selling Products',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: FutureBuilder<BestSellingResponse>(
//         future: _bestSellingFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData ||
//               snapshot.data!.bestsellingReport.isEmpty) {
//             return const Center(
//               child: Text('No best selling products available'),
//             );
//           }
//
//           final products = snapshot.data!.bestsellingReport;
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         height: 45,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(Icons.search, color: Colors.grey),
//                             SizedBox(width: 8),
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(
//                                   hintText: 'Search',
//                                   border: InputBorder.none,
//                                   isCollapsed: true,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       height: 44,
//                       width: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Image.asset(
//                         "assets/images/export_email.png",
//                         height: 20,
//                         width: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       height: 44,
//                       width: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Image.asset(
//                         "assets/images/tunning.png",
//                         height: 20,
//                         width: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     return BestSellingCard(
//                       image: product.imagePath,
//                       name: product.productName,
//                       id: product.productId.toString(),
//                       weight: product.netWeight,
//                       quantity: product.quantity.toString(),
//                       orders: product.orderCount.toString(),
//                       revenue: '\$${product.revenue.toStringAsFixed(2)}',
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
