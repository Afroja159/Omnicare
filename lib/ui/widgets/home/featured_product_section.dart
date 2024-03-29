// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:omnicare_app/Auth/login_screen.dart';
// import 'package:omnicare_app/Model/cart_model.dart';
// import 'package:omnicare_app/services/button_provider.dart';
// import 'package:omnicare_app/const/custom_widgets.dart';
// import 'package:omnicare_app/services/cart_provider.dart';
// import 'package:omnicare_app/ui/network_checker_screen/network_checker_screen.dart';
// import 'package:omnicare_app/ui/screens/cart_screen.dart';
// import 'package:omnicare_app/ui/subscreens/product_details_screen.dart';
// import 'package:omnicare_app/ui/utils/color_palette.dart';
// import 'package:omnicare_app/ui/utils/image_assets.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class FeaturedProductsSection extends StatefulWidget {
//   const FeaturedProductsSection({Key? key}) : super(key: key);
//   @override
//   State<FeaturedProductsSection> createState() =>
//       _FeaturedProductsSectionState();
// }
// class _FeaturedProductsSectionState extends State<FeaturedProductsSection>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;
//
//   List<bool> isFavouriteList = [];
//   List<CartItem> cartItems = [];
//   List<dynamic> featuredproductList = [];
//   bool inProgress = false;
//   bool showAllProducts = false;
//   bool showQuantityButtons = false;
//   int quantity = 0;
//   final List<CartItem> _favorite = [];
//   // Map to store quantity for each product
//   Map<int, int> productQuantities = {};
//   List<Map<String, dynamic>> _wishlistItems = [];
//   @override
//   void initState() {
//     super.initState();
//     fetchWishlist();
//     FeaturedProducts();
//   }
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Fetch wishlist every time the screen is opened
//     fetchWishlist();
//   }
//   Future<void> fetchWishlist() async {
//     try {
//       final String? authToken = await _getAccessToken();
//       if (authToken == null) {
//         print('Authorization token is missing.');
//         return;
//       }
//       final response = await http.get(
//         Uri.parse('https://app.omnicare.com.bd/api/wishlist'),
//         headers: {'Authorization': 'Bearer $authToken'},
//       );
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         // Iterate through the wishlist items and add a timestamp for each item
//         if(mounted){
//           setState(() {
//             _wishlistItems = List<Map<String, dynamic>>.from(responseData['data']).map((item) {
//               return {...item};
//             }).toList();
//           }
//           );}
//       }
//       // else {
//       //   print('Failed to load wishlist. Status code: ${response.statusCode}');
//       //   // Display a message to the user
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(
//       //       content: Text('Failed to load wishlist. Please try again later.'),
//       //       duration: Duration(seconds: 2),
//       //     ),
//       //   );
//       // }
//     } catch (error) {
//       print('Error: $error');
//       // Display a message to the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('An error occurred. Please try again later.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//   void FeaturedProducts() async {
//     inProgress = true;
//     setState(() {});
//     try {
//       final response =
//       await http.get(Uri.parse('https://app.omnicare.com.bd/api'));
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         if(mounted){
//           setState(() {
//             featuredproductList = json['featured_products'];
//             isFavouriteList = List.filled(featuredproductList.length, false);
//           });
//         }
//
//         print(featuredproductList);
//       } else {
//         print(
//             'Failed to load company names. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//     inProgress = false;
//     setState(() {});
//     Provider.of<CartProvider>(context, listen: false).notifyListeners();
//   }
//   Future<void> addToWishlist(int productId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? accessToken = prefs.getString('accessToken');
//     if (accessToken != null) {
//       try {
//         final response = await http.get(
//           Uri.parse('https://app.omnicare.com.bd/api/addToWishlist/$productId'),
//           headers: {'Authorization': 'Bearer $accessToken'},
//         );
//         if (response.statusCode == 200) {
//           // Product added to wishlist successfully
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Product added to wishlist'),
//             ),
//           );
//         } else {
//           // Failed to add product to wishlist
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to add product to wishlist'),
//             ),
//           );
//         }
//       } catch (error) {
//         // Error occurred during request
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('An error occurred. Please try again.'),
//           ),
//         );
//       }
//     } else {
//       // No access token found, user not logged in
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please log in to add to wishlist'),
//         ),
//       );
//     }
//   }
//   Future<void> removeFromWishlist(int wishlistId) async {
//     try {
//       final String? authToken = await _getAccessToken();
//       if (authToken == null) {
//         print('Authorization token is missing.');
//         return;
//       }
//       final Uri url = Uri.parse('https://app.omnicare.com.bd/api/removeFromWishlist/$wishlistId');
//       final response = await http.get(
//         url,
//         headers: {'Authorization': 'Bearer $authToken'},
//       );
//       if (response.statusCode == 200) {
//         print('Product removed from wishlist successfully');
//         // Remove the item from the _wishlistItems list
//         setState(() {
//           _wishlistItems.removeWhere((item) => item['id'] == wishlistId);
//         });
//       } else {
//         print('Failed to remove product from wishlist. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//       // Display a message to the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('An error occurred. Please try again later.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//   void updateFavoriteStatus(List<dynamic> wishlistData) {
//     // Initialize a set to store the product IDs present in the wishlist
//     Set<int> wishlistProductIds = {};
//     // Extract product IDs from the wishlistData and add them to the set
//     for (var item in wishlistData) {
//       var productId = item['product_id'];
//       if (productId != null) {
//         wishlistProductIds.add(productId);
//       }
//     }
//     // Update isFavouriteList based on wishlistProductIds
//     for (int i = 0; i < featuredproductList.length; i++) {
//       var productId = featuredproductList[i]['id'] as int;
//       if (wishlistProductIds.contains(productId)) {
//         // If the product ID exists in the wishlist, set the corresponding index in isFavouriteList to true
//         isFavouriteList[i] = true;
//       } else {
//         // Otherwise, set it to false
//         isFavouriteList[i] = false;
//       }
//     }
//   }
//   Future<void> _handleTokenRefresh(Function onRefreshComplete) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? refreshToken = prefs.getString('refreshToken');
//     if (refreshToken != null) {
//       final String? newAccessToken = await _refreshToken(refreshToken);
//       if (newAccessToken != null) {
//         prefs.setString('accessToken', newAccessToken);
//         await onRefreshComplete();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Session expired. Please log in again.'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         Get.to(() => const LoginScreen());
//       }
//     }
//   }
//   Future<String?> _getAccessToken() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('accessToken');
//   }
//   Future<String?> _refreshToken(String refreshToken) async {
//     final String apiUrl = 'https://app.omnicare.com.bd/api/refresh';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: {
//           'refresh_token': refreshToken,
//         },
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         final Map<String, dynamic> authorization = responseData['authorization'];
//         return authorization['token'];
//       } else {
//         return null;
//       }
//     } catch (error) {
//       print('Error during token refresh: $error');
//       return null;
//     }
//   }
//   void addToCart(int index) {
//     var cartProvider = Provider.of<CartProvider>(context, listen: false);
//     var existingItem = cartItems.firstWhere(
//           (item) => item.name == featuredproductList[index]['name'],
//       orElse: () => CartItem(
//         id: 0,
//         image: 'default_image_path',
//         name: 'Unknown Product',
//         sell_price: 0.0,
//         after_discount_price: 0.0,
//         company_name: 'Unknown Company',
//         subtitle:'Unknown',
//         quantity: 0,
//       ),
//     );
//     if (existingItem.quantity > 0) {
//       cartProvider.updateCartItemQuantity(existingItem, existingItem.quantity);
//       context.read<QuantityButtonsProvider>().setShowQuantityButtons(true);
//     } else {
//       var productId = featuredproductList[index]['id'] as int;
//       var item = CartItem(
//         id: productId,
//         image: featuredproductList[index]['image'] ?? 'default_image_path',
//         name: featuredproductList[index]['name'] ?? 'Unknown Product',
//         sell_price: double.parse('${featuredproductList[index]['sell_price'].replaceAll(',', '')}'),
//         after_discount_price: double.parse(
//             '${featuredproductList[index]['after_discount_price'].replaceAll(',', '')}'),
//         company_name: featuredproductList[index]['brand']['brand_name'] ?? 'Unknown Company',
//         subtitle: featuredproductList[index]['name'] ?? 'Unknown Product',
//         quantity: 1,
//         addedFromProductDetails: true,
//       );
//       cartProvider.addToCart(item);
//       cartProvider.updateQuantity(productId, 1);
//       context.read<QuantityButtonsProvider>().setShowQuantityButtons(false);
//     }
//   }
//   // This method updates the quantity in the productQuantities map
//   void updateProductQuantityInMap(int productId, int newQuantity) {
//     setState(() {
//       productQuantities[productId] = newQuantity;
//       // Check if the new quantity is zero
//       if (newQuantity == 0) {
//         // Remove the product from the cart
//         var cartProvider = Provider.of<CartProvider>(context, listen: false);
//         cartProvider.removeFromCartById(productId);
//       }
//     });
//   }
//   Future<void> _checkNetworkAndLoggedIn() async {
//     bool hasNetwork = await checkNetwork();
//     bool userLoggedIn = await isLoggedIn();
//
//     if (hasNetwork && userLoggedIn) {
//       fetchWishlist();
//     } else {
//       Get.to(() => const NetworkCheckScreen());
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     List<dynamic> displayedProducts = showAllProducts
//         ? featuredproductList
//         : featuredproductList.take(2).toList();
//     cartItems = Provider.of<CartProvider>(context).cartItems;
//     final favoriteProvider = Provider.of<FavoriteProvider>(context);
//     final quantityButtonsProvider = Provider.of<QuantityButtonsProvider>(context);
//     return ChangeNotifierProvider(
//         create: (context) {
//           return QuantityButtonsProvider();
//         },
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Featured Product",
//                   style: fontStyle(12.sp, Colors.black, FontWeight.w400),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       showAllProducts = !showAllProducts;
//                     });
//                   },
//                   child: Text(
//                     showAllProducts ? "Show less" : "See all",
//                     style: fontStyle(12.sp, Colors.black, FontWeight.w400),
//                   ),
//                 )
//               ],
//             ),
//             Consumer<QuantityButtonsProvider>(
//               builder: (context, provider, _) {
//                 bool showQuantityButtons = provider.showQuantityButtons;
//                 return Padding(
//               padding: EdgeInsets.symmetric(vertical: 5.h),
//               child: GridView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 15,
//                   childAspectRatio: 0.60,
//                   mainAxisSpacing: 20,
//                 ),
//                 itemCount: displayedProducts.length,
//                 itemBuilder: (context, index) {
//                   return Stack(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Get.to(
//                             ProductDetailsScreen(
//                               productDetails: featuredproductList[index],
//                             ),
//                           );
//                         },
//                         child: Container(
//                         padding: EdgeInsets.all(8.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5.r),
//                           color: ColorPalette.cardColor,
//                           border: Border.all(color: ColorPalette.primaryColor),
//                           boxShadow: const [
//                             BoxShadow(
//                               blurRadius: 4,
//                               color: Colors.black12,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child:
//                             Column(
//                               children: [
//                                 Expanded(
//                                   flex: 8,
//                                   child: Image.network(
//                                     featuredproductList[index]['image'],
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Image.asset(
//                                         ImageAssets.productJPG,
//                                         scale: 2,
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Expanded(
//                                   flex: 10,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         '${featuredproductList[index]['name']} - ${featuredproductList[index]['brand']['brand_name'].split(' ').first}',
//                                         style: fontStyle(12, Colors.black, FontWeight.w500,
//                                         ),
//                                       ),
//                                       // Text(
//                                       //   '${featuredproductList[index]['brand']['brand_name'].split(' ').take(3).join(' ')}',
//                                       //   style: fontStyle(12, Colors.black, FontWeight.w400,
//                                       //   ),
//                                       // ),
//                                       Text(
//                                         '৳${featuredproductList[index]['after_discount_price']}',
//                                         style: fontStyle(12,
//                                           Colors.black,
//                                           FontWeight.w600,
//                                         ),
//                                       ),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             '৳${featuredproductList[index]['sell_price']}',
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey,
//                                               fontWeight: FontWeight.w400,
//                                               decoration: TextDecoration.lineThrough,
//                                               decorationColor: Colors.red,
//                                               decorationThickness: 3,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 9.w,
//                                           ),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 '৳${double.parse(featuredproductList[index]['discount']).toStringAsFixed(2)}',
//                                                 style: fontStyle(12, Colors.green, FontWeight.w600,
//                                                 ),
//                                               ),
//                                               if (featuredproductList[index]['discount_type']?.toLowerCase() == 'percent')
//                                                 Text(
//                                                   '% Off',
//                                                   style: fontStyle(
//                                                     12, Colors.green, FontWeight.w600,),
//                                                 ),
//                                               if (featuredproductList[index]['discount_type']?.toLowerCase() != 'percent')
//                                                 Text(
//                                                   ' ${featuredproductList[index]['discount_type']}',
//                                                   style: fontStyle(11, Colors.green, FontWeight.w600,
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                       // Display either the "ADD" button or quantity control button
//                                       productQuantities[featuredproductList[index]['id']] == 0 ||
//                                           productQuantities[featuredproductList[index]['id']] == null
//                                           ? InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             productQuantities[featuredproductList[index]['id']] =
//                                                 (productQuantities[featuredproductList[index]['id']] ?? 0) + 1;
//                                             showQuantityButtons = true;
//                                           });
//                                           SchedulerBinding.instance!.addPostFrameCallback((_) {
//                                             addToCart(index);
//                                           });
//                                         },
//                                         child: Container(
//                                           height: 28.h,
//                                           width: 80.w,
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 10.w,
//                                             vertical: 5.h,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: ColorPalette.primaryColor,
//                                             borderRadius:
//                                             BorderRadius.circular(5),
//                                           ),
//                                           child: Center(
//                                             child: Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'ADD',
//                                                   style: fontStyle(12, Colors.white, FontWeight.w400,),
//                                                 ),
//                                                 const Icon(
//                                                   Icons.add, color: Colors.white, size: 18,
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                           : Row(
//                                         children: [
//                                           InkWell(
//                                             onTap: () {
//                                               setState(() {
//                                                 if (productQuantities[featuredproductList[index]['id']] != null &&
//                                                     productQuantities[featuredproductList[index]['id']]! > 0) {
//                                                   productQuantities[featuredproductList[index]['id']] =
//                                                       productQuantities[featuredproductList[index]['id']]! - 1;
//                                                   if (productQuantities[featuredproductList[index]['id']] == 0) {
//                                                     showQuantityButtons = false;
//                                                   }
//                                                 }
//                                                 var cartProvider =
//                                                 Provider.of<CartProvider>(context,
//                                                     listen: false);
//                                                 CartItem? existingItem;
//                                                 try {
//                                                   existingItem = cartProvider.cartItems.firstWhere((item) => item.name == featuredproductList[index]['name'],);
//                                                 } catch (e) {
//                                                   existingItem = null;
//                                                 }
//                                                 if (existingItem != null) {
//                                                   // If the item is already in the cart, increment its quantity
//                                                   existingItem.quantity -= 1;
//                                                   // Notify listeners to update the UI
//                                                   cartProvider.notifyListeners();
//                                                 } else {
//                                                   // If the item is not in the cart, add it
//                                                   var item = CartItem(
//                                                     id: featuredproductList[index]['id'] as int,
//                                                     image: featuredproductList[index]['image'] ?? 'default_image_path',
//                                                     name: featuredproductList[index]['name'] ?? 'Unknown Product',
//                                                     sell_price: double.parse(
//                                                         '${featuredproductList[index]['sell_price'].replaceAll(',', '')}'),
//                                                     after_discount_price: double.parse(
//                                                         '${featuredproductList[index]['after_discount_price'].replaceAll(',', '')}'),
//                                                     company_name: featuredproductList[index]
//                                                     ['brand'] ['brand_name']?? 'Unknown Company',
//                                                     subtitle: featuredproductList[index]['name'] ?? 'Unknown Product',
//                                                     quantity: 1,
//                                                     addedFromProductDetails: true,
//                                                   );
//                                                   // Add the item to the cartProvider
//                                                   cartProvider.addToCart(item);
//
//                                                 }
//                                                 // Notify the CartProvider
//                                                 Provider.of<CartProvider>(context, listen: false).notifyListeners();
//                                                 // Update the product quantity in the map
//                                                 updateProductQuantityInMap(featuredproductList[index]['id'],
//                                                     productQuantities[featuredproductList[index]['id']] ?? 0);
//                                               });
//                                             },
//                                             child: Container(
//                                               padding: const EdgeInsets.all(5),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                 BorderRadius.circular(25),
//                                                 color: ColorPalette.primaryColor,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.remove,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(10.0),
//                                             child: Text(
//                                               '${productQuantities[featuredproductList[index]['id']]}',
//                                               style: fontStyle(
//                                                 18,
//                                                 Colors.black,
//                                                 FontWeight.w400,
//                                               ),
//                                             ),
//                                           ),
//                                           InkWell(
//                                             onTap: () {
//                                               setState(() {
//                                                 productQuantities[featuredproductList[index]['id']] =
//                                                     productQuantities[featuredproductList[index]['id']]! + 1;
//                                                 var cartProvider = Provider.of<CartProvider>(context, listen: false);
//                                                 CartItem? existingItem;
//                                                 try {
//                                                   existingItem = cartProvider.cartItems.firstWhere((item) => item.name == featuredproductList[index]['name'],
//                                                   );
//                                                 } catch (e) {
//                                                   existingItem = null;
//                                                 }
//                                                 if (existingItem != null) {
//                                                   // If the item is already in the cart, increment its quantity
//                                                   existingItem.quantity += 1;
//                                                   // Notify listeners to update the UI
//                                                   cartProvider.notifyListeners();
//                                                 } else {
//                                                   // If the item is not in the cart, add it
//                                                   var item = CartItem(
//                                                     id: featuredproductList[index]['id'] as int,
//                                                     image: featuredproductList[index]['image'] ?? 'default_image_path',
//                                                     name: featuredproductList[index]['name'] ?? 'Unknown Product',
//                                                     sell_price: double.parse('${featuredproductList[index]['sell_price'].replaceAll(',', '')}'),
//                                                     after_discount_price: double.parse('${featuredproductList[index]['after_discount_price'].replaceAll(',', '')}'),
//                                                     company_name: featuredproductList[index]['brand'] ['brand_name']?? 'Unknown Company',
//                                                     subtitle: featuredproductList[index]['name'] ?? 'Unknown Product',
//                                                     quantity: 1,
//                                                     addedFromProductDetails: true,
//                                                   );
//                                                   // Add the item to the cartProvider
//                                                   cartProvider.addToCart(item);
//                                                   // Show a SnackBar to notify the user about the item being added to the cart
//                                                   if (mounted) {
//                                                     ScaffoldMessenger.of(context)
//                                                         .showSnackBar(
//                                                       const SnackBar(content: Text('Added to Cart')),
//                                                     );
//                                                   }
//                                                 }
//                                                 // Update the product quantity in the map
//                                                 updateProductQuantityInMap(
//                                                     featuredproductList[index]['id'],
//                                                     productQuantities[featuredproductList[index]['id']] ?? 0);
//                                               });
//                                               // Notify the CartProvider
//                                               // Provider.of<CartProvider>(context, listen: false).notifyListeners();
//                                             },
//                                             child: Container(
//                                               padding: const EdgeInsets.all(5),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                 BorderRadius.circular(25),
//                                                 color: ColorPalette.primaryColor,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.add,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                                             ),
//                       ),
//                       Positioned(
//                         top: 10.h,
//                         right: 10.w,
//                   child: GestureDetector(
//                     onTap: () async {
//                       // Toggle the favorite status in the provider
//                       favoriteProvider.toggleFavorite(featuredproductList[index]['id']);
//                       // Perform the appropriate action based on the updated status
//                       if (favoriteProvider.isFavorite(featuredproductList[index]['id'])) {
//                         // If the product is now in the wishlist, add it
//                         await addToWishlist(featuredproductList[index]['id']);
//                       } else {
//                         int? wishlistId; // Initialize with null
//
// // Print _wishlistItems to ensure it contains the expected data
//                         print('_wishlistItems: $_wishlistItems');
//
// // Retrieve the wishlist ID from _wishlistItems
//                         for (var item in _wishlistItems) {
//                           String productId = item['product_id'];
//                           int wishlistProductId = int.tryParse(productId) ?? -1;
//
//                           // Print productId and wishlistProductId to see their values
//                           print('productId: $productId, wishlistProductId: $wishlistProductId');
//
//                           if (wishlistProductId == featuredproductList[index]['id']) {
//                             wishlistId = item['id'];
//                             break;
//                           }
//                         }
// // Print wishlistId to see if it was found
//                         print('wishlistId: $wishlistId');
// // Pass the retrieved wishlist ID to removeFromWishlist
//                         if (wishlistId != null) { // Check if wishlistId was found
//                           await removeFromWishlist(wishlistId);
//                         } else {
//                           print('Wishlist ID not found for the product.');
//                         }
//                       }
//                     },
//                     child: Icon(
//                       // Use isFavorite method to determine the initial state of the favorite icon
//                       favoriteProvider.isFavorite(featuredproductList[index]['id'])
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       color: const Color(0xffE40404),
//                     ),
//                   ),
//
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             );
//   },
//   ),
//           ],
//         ),
//     );
//   }
// }
