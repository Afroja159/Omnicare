import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnicare_app/controller/company_controller.dart';
import 'package:omnicare_app/hive/company_hive/company_hive_service.dart';
import 'package:omnicare_app/hive/company_hive/company_model.dart';
import 'package:omnicare_app/ui/screens/company_screen.dart';
import 'package:omnicare_app/ui/widgets/home/company_product_screen.dart';

class CompanySection extends StatelessWidget {
  final CompanyController companyController;

  const CompanySection({required this.companyController});

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
                Get.off(const CompanyScreen());
              },
              child: Text(
                "See all",
                style: TextStyle(fontSize: 12,  fontWeight: FontWeight.w400, color: Colors.black),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 90, // Set the height according to your design
          child: Obx(() {
            final List<Company> companies = companyController.companyList;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      final companyId = company.id;
                      if (companyId != null) {
                        print('Navigating to CompanyProductsScreen with Company ID: $companyId');
                        Get.to(CompanyProductsScreen(companyId: companyId));
                      } else {
                        print('Company ID is null for this entry');
                        // You can show a snackbar or any other UI feedback here
                      }
                    },
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
                            child: Image(
                              image: NetworkImage(company.brandImage),
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                        SizedBox(height: 6), // Adjust spacing between image and name
                        Text(
                          company.brandName.split(' ').first ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}