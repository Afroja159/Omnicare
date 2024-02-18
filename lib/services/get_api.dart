import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:omnicare_app/Model/product_model.dart';

Future getCompany() async {
  String url = "https://app.omnicare.com.bd/api";
  http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    log("Company data: $data company data");
    return ProductModel.fromJson(data);
  } else {
    throw Exception(
        "Something went wrong!. Your status code: ${response.statusCode}");
  }
}
