// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:omnicare_app/Model/product_model.dart';
import 'package:omnicare_app/services/get_api.dart';
import 'package:omnicare_app/ui/screens/company_screen.dart';
import 'package:omnicare_app/ui/utils/color_palette.dart';
import 'package:omnicare_app/ui/widgets/home/company_product_screen.dart';

class CompanySection extends StatelessWidget {
  const CompanySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "All Company",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            TextButton(
              onPressed: () {
                Get.off(() => const CompanyScreen());
              },
              child: Text(
                "See all",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 90.h,
          child: FutureBuilder(
            future: getCompany(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                ProductModel data = snapshot.data;

                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: data.brands.length + 1,
                  itemBuilder: (context, index) {
                    if (index < data.brands.length) {
                      final company = data.brands[index];
                      return InkWell(
                        onTap: () {
                          Get.to(
                                () => CompanyProductsScreen(companyId: company.id!),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Column(
                            children: [
                              Container(
                                width: 90,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                    imageUrl: company.brandImage.toString(),
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                        Center(
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                company.brandName!.split(' ').first,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.off(() => const CompanyScreen());
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: ColorPalette.primaryColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                "See More",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
