import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:omnicare_app/Auth/login_screen.dart';
import 'package:omnicare_app/Model/cart_model.dart';
import 'package:omnicare_app/services/cart_provider.dart';
import 'package:omnicare_app/ui/network_checker_screen/network_checker_screen.dart';
import 'package:omnicare_app/ui/screens/cart_screen.dart';
import 'package:omnicare_app/ui/utils/color_palette.dart';
import 'package:omnicare_app/ui/utils/image_assets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  const ProductDetailsScreen({Key? key, required this.productDetails})
      : super(key: key);
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}
class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isFavourite = false;
  List<Map<String, dynamic>> _wishlistItems = [];
  int quantity = 0;
  double extractSellingPrice() {
    final dynamic sellingPrice = widget.productDetails['sell_price'];
    if (sellingPrice is num || sellingPrice is String) {
      return double.tryParse(sellingPrice.toString().replaceAll(',', '')) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkNetworkAndLoggedIn();
    // Load favorite status from SharedPreferences when the widget initializes
    loadFavoriteStatus();
    //fetchWishlist();
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
        setState(() {
          _wishlistItems = List<Map<String, dynamic>>.from(responseData['data']).map((item) {
            return {...item, };
          }).toList();
        });
        // Sort the wishlist items based on the timestamp, with the latest added item appearing first
        //  _wishlistItems.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
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
  Future<void> addToWishlist(int productId, BuildContext context) async {
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
          // Toggle favorite status using the FavoriteProvider
          Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(productId);
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
  Future<void> removeFromWishlist(String productId) async {
    try {
      final String? authToken = await _getAccessToken();
      if (authToken == null) {
        print('Authorization token is missing.');
        return;
      }
      print('Wishlist items before removal: $_wishlistItems');
      // Find the wishlist item index with the matching product ID
      final int wishlistIndex = _wishlistItems.indexWhere((item) => item['product_id'] == productId);
      if (wishlistIndex == -1) {
        print('Wishlist item not found for product ID: $productId');
        return;
      }
      final int wishlistId = _wishlistItems[wishlistIndex]['id'];
      final Uri url = Uri.parse('https://app.omnicare.com.bd/api/removeFromWishlist/$wishlistId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        print('Product removed from wishlist successfully');
        // Remove the item from the _wishlistItems list
        setState(() {
          _wishlistItems.removeAt(wishlistIndex);
          isFavourite = false;
        });
        // Update the favorite icon wherever the product is used
        Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(int.parse(productId));
      } else {
        print('Failed to remove product from wishlist. Status code: ${response.statusCode}');
        // Display a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove product from wishlist. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
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
  Future<void> loadFavoriteStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int productId = widget.productDetails['id'];
    final bool? isFavorite = prefs.getBool('isFavorite_$productId');
    if (isFavorite != null) {
      setState(() {
        this.isFavourite = isFavorite;
      });
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
        final Map<String, dynamic> authorization = responseData['authorization'];
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
  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context, listen: false);
    double sell_price = extractSellingPrice();
    var favoriteProvider = Provider.of<FavoriteProvider>(context);
    bool isFavorite = favoriteProvider.isFavorite(widget.productDetails['id']) || this.isFavourite;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorPalette.primaryColor,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: const Icon(Icons.arrow_back,color: Colors.white,)),
          title: const Text('Product Details', style: TextStyle(color: Colors.white),),centerTitle: true,),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          widget.productDetails['image'] ?? '', // Use an empty string if image URL is null
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Return a fallback image when an error occurs
                            return Image.asset(ImageAssets.productJPG, fit: BoxFit.cover);
                          },
                        ),
                      ),
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: // Inside the build method of ProductDetailsScreen
                        Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, _) {
                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                                // favoriteProvider.isFavorite(widget.productDetails['id']) ? Icons.favorite : Icons.favorite_border,
                                // color: favoriteProvider.isFavorite(widget.productDetails['id']) ? Colors.red : null,
                              ),
                              onPressed: () async {
                                // String productId = widget.productDetails['id'].toString(); // Convert to string
                                //  if (favoriteProvider.isFavorite(int.parse(productId))) {
                                String productId = widget.productDetails['id'].toString();
                                if (isFavorite) {
                                  // Remove from wishlist if already favorited
                                  await removeFromWishlist(productId);
                                }
                                else {
                                  // Add to wishlist if not already favorited
                                  await addToWishlist(int.parse(productId), context);
                                }
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productDetails['name'] != null
                              ? widget.productDetails['name'] : 'Unknown Product',
                          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Text(
                        //   widget.productDetails['brand'] != null && widget.productDetails['brand']['brand_name'] != null
                        //       ? widget.productDetails['brand']['brand_name'] : 'Unknown company',
                        //   style: const TextStyle(fontSize: 12, color: Color(0xff555555), fontWeight: FontWeight.w400,),
                        // ),
                        Text(
                          (widget.productDetails['brand'] != null && widget.productDetails['brand']['brand_name'] != null)
                              ? widget.productDetails['brand']['brand_name']
                              : (widget.productDetails['company_name'] != null
                              ? widget.productDetails['company_name']
                              : 'Unknown company'),
                          style: const TextStyle(fontSize: 12, color: Color(0xff555555), fontWeight: FontWeight.w400,),
                        ),


                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Product Price',
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '৳ $sell_price'.replaceAll(',', ''),
                      style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w400, decoration: TextDecoration.lineThrough, decorationColor: Colors.red, decorationThickness: 3),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Product Quantity",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (quantity > 0) {
                                quantity--;
                              }
                             // widget.productDetails['quantity'] = (int.parse(widget.productDetails['quantity'].toString()) ?? 1) - 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: ColorPalette.primaryColor,
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400),
                          ),
                          // Text(
                          //   "${widget.productDetails['quantity'] ?? 1} ",
                          //   style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400,),
                          // ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              quantity++;
                             // widget.productDetails['quantity'] = (int.parse(widget.productDetails['quantity'].toString()) ?? 1) + 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: ColorPalette.primaryColor,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "৳ ${widget.productDetails['after_discount_price'] != null && quantity != null ?
                      (double.parse(widget.productDetails['after_discount_price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0) * quantity : 0}",
                      style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w400,),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        // minWidth: 330.w,
                        color: ColorPalette.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        onPressed: () {
                          if (quantity > 0) {
                            // Check if the product is already in the cart
                            final existingCartItem = cartProvider.cartItems.firstWhere(
                                  (item) => item.id == widget.productDetails['id'] && item.addedFromProductDetails,
                              orElse: () => CartItem(
                                id: 0, // Provide a default ID, it could be anything you want
                                image: '', // Provide default values for other fields as well
                                name: '',
                                company_name: '',
                                sell_price: 0.0,
                                after_discount_price: 0.0,
                                subtitle: '',
                                quantity: 0,
                                addedFromProductDetails: true,
                              ),
                            );

                            if (existingCartItem.id != 0) {
                              // If the product is in the cart, increment its quantity
                              cartProvider.updateCartItemQuantity(existingCartItem, existingCartItem.quantity + quantity);
                            } else {
                              // If the product is not in the cart, add it
                              double totalPrice = double.parse(widget.productDetails['after_discount_price'].replaceAll(',', '') ?? '0.0');
                              var item = CartItem(
                                id: widget.productDetails['id'] != null
                                    ? int.tryParse(widget.productDetails['id'].toString()) ?? 0 : 0,
                                image: widget.productDetails['image'] ?? 'default_image_path',
                                name: widget.productDetails['name'] ?? 'Unknown Product',
                                company_name: widget.productDetails['brand']['brand_name'] ?? 'Unknown',
                                sell_price: extractSellingPrice(),
                                after_discount_price: totalPrice,
                                subtitle: widget.productDetails['subtitle'] ?? 'Unknown',
                                quantity: quantity,
                                addedFromProductDetails: true,
                              );
                              cartProvider.addToCart(item);
                            }

                            // Show a SnackBar to notify the user.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  height: 30.h,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Added to cart'),
                                      TextButton(
                                        onPressed: () {
                                          Get.to(const CartScreen());
                                        },
                                        child: const Text('View', style: TextStyle(color: Colors.yellow)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a SnackBar to notify the user that quantity should be greater than 0.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Quantity should be greater than 0 to add to cart'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8.w), // Adjust the margin as needed
                      child: InkWell(
                        onTap: (){
                          Get.to(const CartScreen());
                        },
                        child: const Icon(
                          Icons.shopping_cart, // You can replace this with your cart icon
                          color: Colors.black, // Set the desired color for the icon
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Details",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      widget.productDetails['long_desc'] != null
                          ? widget.productDetails['long_desc']
                          : '',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black, height: 1.8, wordSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}