import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:omnicare_app/Model/cart_model.dart';
import 'package:omnicare_app/const/bottom_navbar.dart';
import 'dart:convert';

import 'package:omnicare_app/ui/subscreens/order_confirm_screen.dart';
import 'package:omnicare_app/ui/utils/color_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  const PaymentMethodScreen({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late double totalPrice;
  int selectedValue = 1;
  int selectedDeliveryValue = 1;
  double discount = 0.0;
  double shipCharge = 0.0;
  String couponCode = '';
  late Future<Map<String, dynamic>> deliveryChargeDataFuture;// Declare deliveryChargeData here

  @override
  void initState() {
    super.initState();
    // Initialize totalPrice using the widget property
    totalPrice = widget.totalPrice;
    // Fetch delivery charge information in initState
    deliveryChargeDataFuture = fetchDeliveryCharge();

  }
// Function to clear the cart
//   Future<void> clearCart() async {
//     try {
//       // Remove all items from the cart
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.remove('cartItems');
//       // Update the UI by setting the cartItems to an empty list
//       setState(() {
//         widget.cartItems.clear();
//         totalPrice = 0.0; // Reset the total price
//       });
//       // Show a success message or perform any other action if needed
//       print('Cart cleared successfully');
//     } catch (error) {
//       // Handle any errors that occur during cart clearing
//       print('Error clearing cart: $error');
//     }
//   }
  Future<void> clearCart() async {
    try {
      // Remove all items from the cart
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('cartItems');
      // Update the UI by setting the cartItems to an empty list
      setState(() {
        widget.cartItems.clear();
        totalPrice = 0.0; // Reset the total price
      });
      // Show a success message or perform any other action if needed
      print('Cart cleared successfully');
    } catch (error) {
      // Handle any errors that occur during cart clearing
      print('Error clearing cart: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: FutureBuilder<Map<String, dynamic>>(
          future: deliveryChargeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(), // Display loading indicator
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error fetching data'), // Display error message
              );
            } else {
              // Data has been successfully fetched
              final deliveryChargeData = snapshot.data!;
              return Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Payment Method",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        height: 48.h,
                        width: 328.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xffB7D4FF)),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Cash on Delivery",
                                style: TextStyle(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                              Radio(
                                value: 1,
                                groupValue: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value!;
                                  });
                                },
                                activeColor: const Color(0xff4E94FC),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h,),
                      Text(
                        "Delivery Area",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20.h,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 48.h,
                              //width: 150.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xffB7D4FF)),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Inside Dhaka",
                                      style: TextStyle(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w500),
                                    ),

                                    Radio(
                                      value: 1,
                                      groupValue: selectedDeliveryValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDeliveryValue = value!;
                                        });
                                      },
                                      activeColor: const Color(0xff4E94FC),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          Expanded(
                            child: Container(
                              height: 48.h,
                              // width: 150.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xffB7D4FF)),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Outside Dhaka",
                                      style: TextStyle(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w500),
                                    ),


                                    Radio(
                                      value: 2,
                                      groupValue: selectedDeliveryValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDeliveryValue = value!;
                                        });
                                      },
                                      activeColor: const Color(0xff4E94FC),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Delivery Charge:",
                                  style: TextStyle(fontSize: 12.sp, color: ColorPalette.primaryColor, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  selectedDeliveryValue == 1
                                      ? '৳ ${deliveryChargeData['ship_charge_inside_dhaka'] ?? '0.0'}'
                                      : selectedDeliveryValue == 2
                                      ? '৳ ${deliveryChargeData['ship_charge_ouside_dhaka'] ?? '0.0'}'
                                      : '', // Display blank if no button is selected
                                  style: TextStyle(fontSize: 12.sp, color: ColorPalette.primaryColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Price:",
                                  style: TextStyle(fontSize: 12.sp, color: ColorPalette.primaryColor, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '৳ $totalPrice',
                                  style: TextStyle(fontSize: 12.sp, color: ColorPalette.primaryColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                            // ----------------------------------------- Button --------------------------------------------
                            MaterialButton(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              minWidth: double.infinity,
                              color: ColorPalette.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              onPressed: () {
                                // Call the placeOrder function
                                placeOrder();
                              },
                              child: Text(
                                "Confirm",
                                style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),

    );
  }

  Future<Map<String, dynamic>> fetchDeliveryCharge() async {
    final apiUrl = 'https://app.omnicare.com.bd/api/settings';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['site_settigs'][0];
      } else {
        // Handle errors, print error response
        print('Failed to fetch delivery charge information');
        print('Response: ${response.body}');
        throw Exception('Failed to fetch delivery charge information');
      }
    } catch (error) {
      // Handle network errors
      print('Error: $error');
      throw Exception('Network error: $error');
    }
  }

  Future<void> placeOrder() async {
    // Fetch delivery charge information
    Map<String, dynamic> deliveryChargeData = await fetchDeliveryCharge();
    final apiUrl = 'https://app.omnicare.com.bd/api/checkout';

    // Prepare payload for the API request
    final payload = {
      'cart_orders': widget.cartItems.map((item) {
        return {
          'product_id': item.id,
          'product_price': item.after_discount_price.toString(),
          'product_quantity': item.quantity,
        };
      }).toList(),
      'discount': discount,
      'ship_charge': selectedDeliveryValue == 1
          ? deliveryChargeData['ship_charge_inside_dhaka']
          : deliveryChargeData['ship_charge_ouside_dhaka'],
      'cupon_code': couponCode,
      'payment_type': selectedValue,
      'total_price': totalPrice,
    };

    try {
      // Get the current access token using the token refresh logic
      final String? accessToken = await _getAccessToken();

      if (accessToken != null) {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(payload),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          // Order placed successfully, you can handle the response accordingly
          print('Order placed successfully');
          print('Response: ${response.body}');


          // Navigate to the order confirmation screen
          Get.offAll(const OrderConfirmedScreen());
          // Clear the cart
          await clearCart();
        } else {
          // Handle errors, print error response
          print('Failed to place order');
          print('Response: ${response.body}');
          // You may want to show an error message to the user
          // Example: showSnackBar('Failed to place order');
        }
      } else {
        // Handle the case where the access token is not available
        print('Access token is null');
      }
    } catch (error) {
      // Handle network errors
      print('Error: $error');
      // You may want to show an error message to the user
      // Example: showSnackBar('Network error');
    }
  }


  // Function to handle token refresh
  Future<void> _handleTokenRefresh(Function onRefreshComplete) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      final String? newAccessToken = await _refreshToken(refreshToken);

      if (newAccessToken != null) {
        // Save the new access token
        prefs.setString('accessToken', newAccessToken);

        // Retry the original function after token refresh
        await onRefreshComplete();
      } else {
        // If refresh token is not available or refresh fails, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Function to get the current access token
  Future<String?> _getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Function to refresh the access token
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
}

