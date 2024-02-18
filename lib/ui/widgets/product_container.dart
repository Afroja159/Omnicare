// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnicare_app/const/custom_widgets.dart';
import 'package:omnicare_app/ui/utils/color_palette.dart';
import 'package:omnicare_app/ui/utils/image_assets.dart';

Widget productContainer({
  required VoidCallback onTap,
  required bool isDiscountPercent,
  required int cartItem,
}) {
  return SizedBox(
    child: Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: ColorPalette.cardColor,
              border: Border.all(color: ColorPalette.primaryColor),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.black12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 8,
                  child: Image.network(
                    'https://app.omnicare.com.bd//public/uploads/1707646939.jpg',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///product & brand name
                      Text(
                        'Artica 10 mg tab - ACI',
                        style: fontStyle(
                          12,
                          Colors.black,
                          FontWeight.w500,
                        ),
                      ),

                      ///discount price
                      Text(
                        '৳ 275',
                        style: fontStyle(12.sp, Colors.black, FontWeight.w600),
                      ),

                      ///without discount price & discount
                      Row(
                        children: [
                          /// discount price
                          Text(
                            '৳ 312',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red,
                              decorationThickness: 3,
                            ),
                          ),
                          SizedBox(
                            width: 9.w,
                          ),

                          ///there are two type of discount-->1.percent 2.flat
                          isDiscountPercent
                              ? Row(
                            children: [
                              ///discount percent
                              Text(
                                '৳${123.489.toStringAsFixed(2)}',
                                style: fontStyle(
                                  12,
                                  Colors.green,
                                  FontWeight.w600,
                                ),
                              ),

                              Text(
                                '% Off',
                                style: fontStyle(
                                  12,
                                  Colors.green,
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                              : Text(
                            ' 23',
                            style: fontStyle(
                              11,
                              Colors.green,
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      ///cart button
                      cartItem <= 0
                          ? Container(
                        height: 28.h,
                        width: 80.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                      )

                      ///cart item quantity increase and decrease
                          : Row(
                        children: [
                          InkWell(
                            onTap: () {},
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
                              '2',
                              style: fontStyle(
                                18,
                                Colors.black,
                                FontWeight.w400,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
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
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
