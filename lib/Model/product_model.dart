class ProductModel {
  ProductModel({
    required this.sliders,
    required this.offeredProducts,
    required this.allProducts,
    required this.brands,
    required this.siteSettigs,
  });

  final List<Slider> sliders;
  final List<Product> offeredProducts;
  final List<Product> allProducts;
  final List<BrandElement> brands;
  final List<SiteSettig> siteSettigs;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      sliders: json["sliders"] == null
          ? []
          : List<Slider>.from(json["sliders"]!.map((x) => Slider.fromJson(x))),
      offeredProducts: json["offered_products"] == null
          ? []
          : List<Product>.from(
          json["offered_products"]!.map((x) => Product.fromJson(x))),
      allProducts: json["all_products"] == null
          ? []
          : List<Product>.from(
          json["all_products"]!.map((x) => Product.fromJson(x))),
      brands: json["brands"] == null
          ? []
          : List<BrandElement>.from(
          json["brands"]!.map((x) => BrandElement.fromJson(x))),
      siteSettigs: json["site_settigs"] == null
          ? []
          : List<SiteSettig>.from(
          json["site_settigs"]!.map((x) => SiteSettig.fromJson(x))),
    );
  }
}

class Product {
  Product({
    required this.id,
    required this.discount,
    required this.discountType,
    required this.afterDiscountPrice,
    required this.name,
    required this.image,
    required this.unit,
    required this.quantity,
    required this.sellPrice,
    required this.longDesc,
    required this.category,
    required this.brand,
  });

  final int? id;
  final String? discount;
  final String? discountType;
  final String? afterDiscountPrice;
  final String? name;
  final String? image;
  final String? unit;
  final String? quantity;
  final String? sellPrice;
  final dynamic longDesc;
  final Category? category;
  final AllProductBrand? brand;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      discount: json["discount"],
      discountType: json["discount_type"],
      afterDiscountPrice: json["after_discount_price"],
      name: json["name"],
      image: json["image"],
      unit: json["unit"],
      quantity: json["quantity"],
      sellPrice: json["sell_price"],
      longDesc: json["long_desc"],
      category:
      json["category"] == null ? null : Category.fromJson(json["category"]),
      brand: json["brand"] == null
          ? null
          : AllProductBrand.fromJson(json["brand"]),
    );
  }
}

class AllProductBrand {
  AllProductBrand({
    required this.id,
    required this.brandName,
  });

  final int? id;
  final String? brandName;

  factory AllProductBrand.fromJson(Map<String, dynamic> json) {
    return AllProductBrand(
      id: json["id"],
      brandName: json["brand_name"],
    );
  }
}

class Category {
  Category({
    required this.id,
    required this.categoryName,
  });

  final int? id;
  final String? categoryName;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      categoryName: json["category_name"],
    );
  }
}

class BrandElement {
  BrandElement({
    required this.id,
    required this.brandName,
    required this.brandImage,
  });

  final int? id;
  final String? brandName;
  final String? brandImage;

  factory BrandElement.fromJson(Map<String, dynamic> json) {
    return BrandElement(
      id: json["id"],
      brandName: json["brand_name"],
      brandImage: json["brand_image"],
    );
  }
}

class SiteSettig {
  SiteSettig({
    required this.id,
    required this.title,
    required this.headerIcon,
    required this.helpNumber,
    required this.bannerImage,
    required this.notificationText1,
    required this.notificationText2,
    required this.notificationText3,
    required this.notificationText4,
    required this.notificationText5,
    required this.shipChargeInsideDhaka,
    required this.shipChargeOusideDhaka,
  });

  final int? id;
  final String? title;
  final String? headerIcon;
  final String? helpNumber;
  final String? bannerImage;
  final String? notificationText1;
  final String? notificationText2;
  final dynamic notificationText3;
  final dynamic notificationText4;
  final dynamic notificationText5;
  final String? shipChargeInsideDhaka;
  final String? shipChargeOusideDhaka;

  factory SiteSettig.fromJson(Map<String, dynamic> json) {
    return SiteSettig(
      id: json["id"],
      title: json["title"],
      headerIcon: json["header_Icon"],
      helpNumber: json["help_number"],
      bannerImage: json["banner_image"],
      notificationText1: json["notification_text_1"],
      notificationText2: json["notification_text_2"],
      notificationText3: json["notification_text_3"],
      notificationText4: json["notification_text_4"],
      notificationText5: json["notification_text_5"],
      shipChargeInsideDhaka: json["ship_charge_inside_dhaka"],
      shipChargeOusideDhaka: json["ship_charge_ouside_dhaka"],
    );
  }
}

class Slider {
  Slider({
    required this.id,
    required this.sliderTitle,
    required this.sliderImage,
  });

  final int? id;
  final String? sliderTitle;
  final String? sliderImage;

  factory Slider.fromJson(Map<String, dynamic> json) {
    return Slider(
      id: json["id"],
      sliderTitle: json["slider_title"],
      sliderImage: json["slider_image"],
    );
  }
}
