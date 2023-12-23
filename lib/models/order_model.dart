class UserOrder {
  String? sId;
  String? userId;
  int? orderState;
  String? image;
  num? cost;
  String? address;
  String? date;
  int? iV;

  UserOrder(
      {this.sId,
      this.userId,
      this.orderState,
      this.image,
      this.cost,
      this.address,
      this.date,
      this.iV});

  UserOrder.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    orderState = json['orderState'];
    image = json['image'];
    cost = json['cost'];
    address = json['address'];
    date = json['date'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['orderState'] = this.orderState;
    data['image'] = this.image;
    data['cost'] = this.cost;
    data['address'] = this.address;
    data['date'] = this.date;
    data['__v'] = this.iV;
    return data;
  }
}

class OrderDetail {
  String? sId;
  String? orderId;
  String? foodId;
  int? quantity;
  num? priceNow;
  int? iV;
  List<FoodInfomation>? foodInfomation;

  OrderDetail(
      {this.sId,
      this.orderId,
      this.foodId,
      this.quantity,
      this.priceNow,
      this.iV,
      this.foodInfomation});

  OrderDetail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    orderId = json['orderId'];
    foodId = json['foodId'];
    quantity = json['quantity'];
    priceNow = json['priceNow'];
    iV = json['__v'];
    if (json['foodInfomation'] != null) {
      foodInfomation = <FoodInfomation>[];
      json['foodInfomation'].forEach((v) {
        foodInfomation!.add(new FoodInfomation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['orderId'] = this.orderId;
    data['foodId'] = this.foodId;
    data['quantity'] = this.quantity;
    data['priceNow'] = this.priceNow;
    data['__v'] = this.iV;
    if (this.foodInfomation != null) {
      data['foodInfomation'] =
          this.foodInfomation!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FoodInfomation {
  String? sId;
  String? foodName;
  num? price;
  List<String>? foodType;
  String? image;
  String? description;
  num? rate;
  int? iV;
  List<StateFood>? stateFood;

  FoodInfomation(
      {this.sId,
      this.foodName,
      this.price,
      this.foodType,
      this.image,
      this.description,
      this.rate,
      this.iV,
      this.stateFood});

  FoodInfomation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    foodName = json['foodName'];
    price = json['price'];
    foodType = json['foodType'].cast<String>();
    image = json['image'];
    description = json['description'];
    rate = json['rate'];
    iV = json['__v'];
    if (json['stateFood'] != null) {
      stateFood = <StateFood>[];
      json['stateFood'].forEach((v) {
        stateFood!.add(new StateFood.fromJson(v));
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
    if (this.stateFood != null) {
      data['stateFood'] = this.stateFood!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StateFood {
  int? foodDiscount;

  StateFood({this.foodDiscount});

  StateFood.fromJson(Map<String, dynamic> json) {
    foodDiscount = json['foodDiscount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['foodDiscount'] = this.foodDiscount;
    return data;
  }
}
