// ignore_for_file: avoid_print, use_build_context_synchronously, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element, prefer_const_declarations, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:omnicare_app/Auth/login_screen.dart';
import 'package:omnicare_app/Model/cart_model.dart';
import 'package:omnicare_app/services/button_provider.dart';
import 'package:omnicare_app/const/custom_widgets.dart';
import 'package:omnicare_app/services/cart_provider.dart';
import 'package:omnicare_app/ui/network_checker_screen/network_checker_screen.dart';
import 'package:omnicare_app/ui/subscreens/product_details_screen.dart';
import 'package:omnicare_app/ui/utils/color_palette.dart';
import 'package:omnicare_app/ui/utils/image_assets.dart';
import 'package:http/http.dart' as http;
import 'package:omnicare_app/ui/widgets/home/see_all_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllProductSection extends StatefulWidget {
  const AllProductSection({
    super.key,
  });
  @override
  State<AllProductSection> createState() => _AllProductSectionState();
}

class _AllProductSectionState extends State<AllProductSection> {
  List<bool> isFavouriteList = [];
  List<dynamic> allproductsList = [];
  bool inProgress = false;
  bool showAllProducts =
  false; // Variable to track whether to show all products// Variable to track whether to show all products
  List<CartItem> cartItems = [];
  bool showQuantityButtons = false;
  int quantity = 0;
  // Map to store quantity for each product
  Map<int, int> productQuantities = {};
  List<Map<String, dynamic>> _wishlistItems = [];
  @override
  void initState() {
    super.initState();
    fetchWishlist();
    AllProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch wishlist every time the screen is opened
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      final String? authToken = await _getAccessToken();
      if (authToken == null) {
        print('Authorization token is missing.');
        return;
      }
      final response = await http.get(
        Uri.parse('https://app.omnicare.com.bd/api/wishlist'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Iterate through the wishlist items and add a timestamp for each item
        if (mounted) {
          setState(() {
            _wishlistItems =
                List<Map<String, dynamic>>.from(responseData['data'])
                    .map((item) {
                  return {...item};
                }).toList();
          });
        }
      }
      // else {
      //   print('Failed to load wishlist. Status code: ${response.statusCode}');
      //   // Display a message to the user
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to load wishlist. Please try again later.'),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      // }
    } catch (error) {
      print('Error: $error');
      // Display a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void AllProducts() async {
    inProgress = true;
    setState(() {});
    try {
      final response =
      await http.get(Uri.parse('https://app.omnicare.com.bd/api'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            allproductsList = json['all_products'];
            isFavouriteList = List.filled(allproductsList.length, false);
          });
        }

        print(allproductsList);
      } else {
        print(
            'Failed to load company names. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    inProgress = false;
    setState(() {});
    Provider.of<CartProvider>(context, listen: false).notifyListeners();
  }

  Future<void> addToWishlist(int productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('https://app.omnicare.com.bd/api/addToWishlist/$productId'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        if (response.statusCode == 200) {
          // Product added to wishlist successfully
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Product added to wishlist'),
          //   ),
          // );
        } else {
          // Failed to add product to wishlist
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Failed to add product to wishlist'),
          //   ),
          // );
        }
      } catch (error) {
        // Error occurred during request
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
          ),
        );
      }
    } else {
      // No access token found, user not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add to wishlist'),
        ),
      );
    }
  }

  Future<void> removeFromWishlist(int wishlistId) async {
    try {
      final String? authToken = await _getAccessToken();
      if (authToken == null) {
        print('Authorization token is missing.');
        return;
      }
      final Uri url = Uri.parse(
          'https://app.omnicare.com.bd/api/removeFromWishlist/$wishlistId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        print('Product removed from wishlist successfully');
        // Remove the item from the _wishlistItems list
        setState(() {
          _wishlistItems.removeWhere((item) => item['id'] == wishlistId);
        });
      } else {
        print(
            'Failed to remove product from wishlist. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      // Display a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void updateFavoriteStatus(List<dynamic> wishlistData) {
    // Initialize a set to store the product IDs present in the wishlist
    Set<int> wishlistProductIds = {};
    // Extract product IDs from the wishlistData and add them to the set
    for (var item in wishlistData) {
      var productId = item['product_id'];
      if (productId != null) {
        wishlistProductIds.add(productId);
      }
    }
    // Update isFavouriteList based on wishlistProductIds
    for (int i = 0; i < allproductsList.length; i++) {
      var productId = allproductsList[i]['id'] as int;
      if (wishlistProductIds.contains(productId)) {
        // If the product ID exists in the wishlist, set the corresponding index in isFavouriteList to true
        isFavouriteList[i] = true;
      } else {
        // Otherwise, set it to false
        isFavouriteList[i] = false;
      }
    }
  }

  Future<void> _handleTokenRefresh(Function onRefreshComplete) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? refreshToken = prefs.getString('refreshToken');
    if (refreshToken != null) {
      final String? newAccessToken = await _refreshToken(refreshToken);
      if (newAccessToken != null) {
        prefs.setString('accessToken', newAccessToken);
        await onRefreshComplete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            duration: Duration(seconds: 2),
          ),
        );
        Get.to(() => const LoginScreen());
      }
    }
  }

  Future<String?> _getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> _refreshToken(String refreshToken) async {
    final String apiUrl = 'https://app.omnicare.com.bd/api/refresh';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'refresh_token': refreshToken,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> authorization =
        responseData['authorization'];
        return authorization['token'];
      } else {
        return null;
      }
    } catch (error) {
      print('Error during token refresh: $error');
      return null;
    }
  }

  Future<void> _checkNetworkAndLoggedIn() async {
    bool hasNetwork = await checkNetwork();
    bool userLoggedIn = await isLoggedIn();
    if (hasNetwork && userLoggedIn) {
      fetchWishlist();
    } else {
      Get.to(() => const NetworkCheckScreen());
    }
  }

  void addToCart(int index) {
    var cartProvider = Provider.of<CartProvider>(context, listen: false);
    var existingItem = cartItems.firstWhere(
          (item) => item.name == allproductsList[index]['name'],
      orElse: () => CartItem(
        id: 0,
        image: 'default_image_path',
        name: 'Unknown Product',
        sell_price: 0.0,
        after_discount_price: 0.0,
        company_name: 'Unknown Company',
        subtitle: 'Unknown Subtitle',
        quantity: 0,
      ),
    );
    if (existingItem.quantity > 0) {
      cartProvider.updateCartItemQuantity(existingItem, existingItem.quantity);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Container(
      //       height: 30.h,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           const Text('Item is already in the cart'),
      //           TextButton(
      //             onPressed: () {
      //               Get.to(const CartScreen());
      //             },
      //             child: const Text('View', style: TextStyle(color: Colors.yellow)),
      //           )
      //         ],
      //       ),
      //     ),
      //   ),
      // );
      context.read<QuantityButtonsProvider>().setShowQuantityButtons(true);
    } else {
      var productId = allproductsList[index]['id'] as int;
      var item = CartItem(
        id: productId,
        image: allproductsList[index]['image'] ?? 'default_image_path',
        name: allproductsList[index]['name'] ?? 'Unknown Product',
        sell_price: double.parse(
            '${allproductsList[index]['sell_price'].replaceAll(',', '')}'),
        after_discount_price: double.parse(
            '${allproductsList[index]['after_discount_price'].replaceAll(',', '')}'),
        company_name:
        allproductsList[index]['brand']['brand_name'] ?? 'Unknown Company',
        subtitle: allproductsList[index]['name'] ?? 'Unknown Product',
        quantity: 1,
        addedFromProductDetails: true,
      );
      cartProvider.addToCart(item);
      cartProvider.updateQuantity(productId, 1);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Container(
      //       height: 30.h,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           const Text('Added to cart'),
      //           TextButton(
      //             onPressed: () {
      //               Get.to(const CartScreen());
      //             },
      //             child: const Text('View', style: TextStyle(color: Colors.yellow)),
      //           )
      //         ],
      //       ),
      //     ),
      //   ),
      // );
      context.read<QuantityButtonsProvider>().setShowQuantityButtons(false);
    }
  }

  // This method updates the quantity in the productQuantities map
  void updateProductQuantityInMap(int productId, int newQuantity) {
    setState(() {
      productQuantities[productId] = newQuantity;
      // Check if the new quantity is zero
      if (newQuantity == 0) {
        // Remove the product from the cart
        var cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.removeFromCartById(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var cartProviders = Provider.of<CartProvider>(context, listen: false);

    cartItems = Provider.of<CartProvider>(context).cartItems;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    return ChangeNotifierProvider(
      create: (context) {
        return QuantityButtonsProvider();
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "All Product",
                style: fontStyle(12.sp, Colors.black, FontWeight.w400),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    Get.to(() => const SeeAllProductScreen());
                  });
                },
                child: Text(
                  "See all",
                  style: fontStyle(12.sp, Colors.black, FontWeight.w400),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.60,
                mainAxisExtent: 260.h,
              ),
              itemCount: allproductsList.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(
                              () => ProductDetailsScreen(
                            productDetails: allproductsList[index],
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            color: ColorPalette.cardColor,
                            border:
                            Border.all(color: ColorPalette.primaryColor),
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black12,
                                  offset: Offset(0, 2)),
                            ]),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Image.network(
                                '${allproductsList[index]['image']}',
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    ImageAssets.productJPG,
                                    scale: 2,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Expanded(
                              flex: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${allproductsList[index]['name']} - ${allproductsList[index]['brand']['brand_name'].split(' ').first}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: fontStyle(
                                      12,
                                      Colors.black,
                                      FontWeight.w500,
                                    ),
                                  ),

                                  Text(
                                    '৳${allproductsList[index]['after_discount_price'].replaceAll(',', '')}',
                                    style: fontStyle(
                                        12.sp, Colors.black, FontWeight.w600),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '৳${allproductsList[index]['sell_price'].replaceAll(',', '')}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                          decoration:
                                          TextDecoration.lineThrough,
                                          decorationColor: Colors.red,
                                          decorationThickness: 3,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '৳${double.parse(allproductsList[index]['discount']).toStringAsFixed(2)}',
                                            style: fontStyle(12.sp,
                                                Colors.green, FontWeight.w600),
                                          ),
                                          if (allproductsList[index]
                                          ['discount_type']
                                              ?.toLowerCase() ==
                                              'percent')
                                            Text(
                                              '% Off',
                                              style: fontStyle(
                                                  12.sp,
                                                  Colors.green,
                                                  FontWeight.w600),
                                            ),
                                          if (allproductsList[index]
                                          ['discount_type']
                                              ?.toLowerCase() !=
                                              'percent')
                                            Text(
                                              ' ${allproductsList[index]['discount_type']}',
                                              style: fontStyle(
                                                  11.sp,
                                                  Colors.green,
                                                  FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Display either the "ADD" button or quantity control buttons
                                  int.parse(cartProviders
                                      .getProductQuantityById(
                                      allproductsList[index]['id'])
                                      .toString()) ==
                                      0
                                      ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        productQuantities[allproductsList[
                                        index]
                                        ['id']] = (productQuantities[
                                        allproductsList[index]
                                        ['id']] ??
                                            0) +
                                            1;
                                        showQuantityButtons = true;
                                      });
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) {
                                        addToCart(index);
                                      });
                                    },
                                    child: Container(
                                      height: 28.h,
                                      width: 80.w,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorPalette.primaryColor,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              'ADD',
                                              style: fontStyle(
                                                12.sp,
                                                Colors.white,
                                                FontWeight.w400,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                      : Row(
                                    children: [
                                      ///decrement cart quantity
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            var quantity = cartProviders
                                                .getProductQuantityById(
                                              allproductsList[index]
                                              ['id'],
                                            );
                                            quantity--;

                                            cartProviders
                                                .updateQuantityById(
                                              allproductsList[index]
                                              ['id'],
                                              quantity,
                                            );
                                          });
                                        },
                                        child: Container(
                                          padding:
                                          const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(25),
                                            color:
                                            ColorPalette.primaryColor,
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      ///cart quantity
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(10.0),
                                        child: Text(
                                          '${int.parse(cartProviders.getProductQuantityById(allproductsList[index]['id']).toString())}',
                                          style: fontStyle(
                                            18,
                                            const Color.fromARGB(
                                                255, 184, 11, 11),
                                            FontWeight.w400,
                                          ),
                                        ),
                                      ),

                                      ///inecrement cart quantity
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            var quantity = cartProviders
                                                .getProductQuantityById(
                                              allproductsList[index]
                                              ['id'],
                                            );
                                            quantity++;

                                            cartProviders
                                                .updateQuantityById(
                                              allproductsList[index]
                                              ['id'],
                                              quantity,
                                            );
                                          });
                                        },
                                        child: Container(
                                          padding:
                                          const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(25),
                                            color:
                                            ColorPalette.primaryColor,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: GestureDetector(
                        onTap: () async {
                          // Toggle the favorite status in the provider
                          favoriteProvider
                              .toggleFavorite(allproductsList[index]['id']);
                          // Perform the appropriate action based on the updated status
                          if (favoriteProvider
                              .isFavorite(allproductsList[index]['id'])) {
                            // If the product is now in the wishlist, add it
                            await addToWishlist(allproductsList[index]['id']);
                          } else {
                            int? wishlistId; // Initialize with null
// Print _wishlistItems to ensure it contains the expected data
                            print('_wishlistItems: $_wishlistItems');
// Retrieve the wishlist ID from _wishlistItems
                            for (var item in _wishlistItems) {
                              String productId = item['product_id'];
                              int wishlistProductId =
                                  int.tryParse(productId) ?? -1;
                              // Print productId and wishlistProductId to see their values
                              print(
                                  'productId: $productId, wishlistProductId: $wishlistProductId');
                              if (wishlistProductId ==
                                  allproductsList[index]['id']) {
                                wishlistId = item['id'];
                                break;
                              }
                            }
// Print wishlistId to see if it was found
                            print('wishlistId: $wishlistId');
// Pass the retrieved wishlist ID to removeFromWishlist
                            if (wishlistId != null) {
                              // Check if wishlistId was found
                              await removeFromWishlist(wishlistId);
                            } else {
                              print('Wishlist ID not found for the product.');
                            }
                          }
                        },
                        child: Icon(
                          // Use isFavorite method to determine the initial state of the favorite icon
                          favoriteProvider
                              .isFavorite(allproductsList[index]['id'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: const Color(0xffE40404),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
