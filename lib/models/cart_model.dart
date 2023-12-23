class List_cart {
  List<Cart>? cart;

  List_cart({this.cart});

  List_cart.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      cart = <Cart>[];
      json['cart'].forEach((v) {
        cart!.add(new Cart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cart != null) {
      data['cart'] = this.cart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  String? id;
  String? name;
  int? quantity;
  String? image;
  num? price;
  List<String>? type;
  String? idcart;

  Cart(
      {this.id,
      this.name,
      this.quantity,
      this.image,
      this.price,
      this.type,
      this.idcart});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    quantity = json['quantity'];
    image = json['image'];
    price = json['price'];
    type = json['type'] == null
        ? []
        : List<String>.from(json["type"].map((x) => x));
    idcart = json['idcart'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['image'] = this.image;
    data['price'] = this.price;
    data['type'] = this.type;
    data['idcart'] = this.idcart;
    return data;
  }
}
