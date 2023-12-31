class FoodInfo {
  String? sId;
  String? foodName;
  num? price;
  List<String>? foodType;
  String? image;
  String? description;
  num? rate;
  int? iV;
  List<FoodInfoState>? foodInfoState;

  FoodInfo(
      {this.sId,
      this.foodName,
      this.price,
      this.foodType,
      this.image,
      this.description,
      this.rate,
      this.iV,
      this.foodInfoState});

  FoodInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    foodName = json['foodName'];
    price = json['price'];
    foodType = json['foodType'].cast<String>();
    image = json['image'];
    description = json['description'];
    rate = json['rate'];
    iV = json['__v'];
    if (json['foodInfoState'] != null) {
      foodInfoState = <FoodInfoState>[];
      json['foodInfoState'].forEach((v) {
        foodInfoState!.add(new FoodInfoState.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['foodName'] = this.foodName;
    data['price'] = this.price;
    data['foodType'] = this.foodType;
    data['image'] = this.image;
    data['description'] = this.description;
    data['rate'] = this.rate;
    data['__v'] = this.iV;
    if (this.foodInfoState != null) {
      data['foodInfoState'] =
          this.foodInfoState!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FoodInfoState {
  String? sId;
  int? quantity;
  int? foodDiscount;
  String? foodId;
  int? iV;

  FoodInfoState(
      {this.sId, this.quantity, this.foodDiscount, this.foodId, this.iV});

  FoodInfoState.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    quantity = json['quantity'];
    foodDiscount = json['foodDiscount'];
    foodId = json['foodId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['quantity'] = this.quantity;
    data['foodDiscount'] = this.foodDiscount;
    data['foodId'] = this.foodId;
    data['__v'] = this.iV;
    return data;
  }
}
