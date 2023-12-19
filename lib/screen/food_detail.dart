import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:food_app/screen/review.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cart_model.dart';
import '../models/food_model.dart';
import 'package:uuid/uuid.dart';

class Food_detail extends StatefulWidget {
  const Food_detail({
    super.key,
    required this.foodId,
  });

  final String foodId;
  @override
  State<Food_detail> createState() => _Food_detailState();
}

class _Food_detailState extends State<Food_detail> {
  late bool _isLoading;
  final LocalStorage storage = new LocalStorage('cart.json');
  var quantity = 1;
  var uuid = Uuid();
  late Food foodSelected;
  FoodState? foodSelectedState;

  Future<http.Response> getFoodInfo(String id) async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'foodId': id,
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/food/viewFood"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        var jsoncode = jsonDecode(response.body) as Map<String, dynamic>;
        foodSelected = Food.fromJson(jsoncode);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    var checkedSession = await SessionManager().get('cart');

    if (checkedSession != null) {
      debugPrint(checkedSession.runtimeType.toString());
    } else {
      debugPrint("thnhdehdoifhsofh");
    }
    return response;
  }

  Future<void> addToCart(String foodId, String name, int quantity, String image,
      double price, List<String> type) async {
    _isLoading = true;
    var listCart = await SessionManager().get('cart');
    if (listCart != null) {
      List_cart list_local =
          List_cart.fromJson(await SessionManager().get("cart"));
      String codeHiding = uuid.v4();
      Cart item = new Cart(
          id: foodId,
          name: name,
          quantity: quantity,
          image: image,
          price: price,
          type: type,
          idcart: codeHiding);
      list_local.cart?.add(item);
      SessionManager().set("cart", list_local);
      setState(() {
        _isLoading = false;
      });
    } else {
      Cart item = new Cart(
          id: foodId,
          name: name,
          quantity: quantity,
          image: image,
          price: price,
          type: type);
      List_cart list_cart1 = List_cart(cart: [item]);
      storage.setItem('cart', list_cart1);
      SessionManager().set("cart", list_cart1);
      setState(() {
        _isLoading = false;
      });
    }
    return;
  }

  Future<http.Response> getFoodState(String id) async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'foodId': id,
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/food/viewFoodState"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        var jsoncode = jsonDecode(response.body) as Map<String, dynamic>;
        foodSelectedState = FoodState.fromJson(jsoncode);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    return response;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    getFoodInfo(widget.foodId);
    Future.delayed(const Duration(milliseconds: 7000), () {});
    // getFoodInfo(widget.foodId).then((value) => null);
    getFoodState(widget.foodId).then((value) => null);
    // getFoodState(widget.foodId);
  }

  @override
  Widget build(BuildContext context) {
    widget.foodId;
    return _isLoading
        ? LoadingPage()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
                      width: double.maxFinite,
                      height: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: NetworkImage(foodSelected.image!),
                              fit: BoxFit.fitWidth)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.only(left: 15, top: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255))))),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Center(
                                  child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 10,
                                color: Colors.orange,
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        foodSelected.foodName!,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Row(children: [
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          foodSelected.rate!.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Review(
                                        foodId: widget.foodId,
                                      )),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                          child: const Text(
                            "Xem đánh giá",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ]),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${(foodSelected.price! - foodSelected.price! * (int.parse(foodSelectedState!.foodDiscount.toString()) / 100)).round().toStringAsFixed(3)}đ",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  side: BorderSide(
                                                      color: Colors.orange)))),
                                      onPressed: () {
                                        setState(() {
                                          if (quantity >= 2) {
                                            quantity -= 1;
                                          }
                                        });
                                      },
                                      child: Center(
                                          child: Icon(
                                        Icons.remove,
                                        size: 10,
                                        color: Colors.orange,
                                      )),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: 23,
                                    child: Center(
                                      child: Text(
                                        quantity.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.orange),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  side: BorderSide(
                                                      color: Colors.orange)))),
                                      onPressed: () {
                                        setState(() {
                                          quantity += 1;
                                        });
                                      },
                                      child: Center(
                                          child: Icon(
                                        Icons.add,
                                        size: 10,
                                        color: Colors.white,
                                      )),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            )
                          ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 230,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        foodSelected.description.toString(),
                        maxLines: 9,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      side: BorderSide(color: Colors.orange)))),
                          onPressed: () {
                            double foodPrice = foodSelected.price! -
                                foodSelected.price! *
                                    foodSelectedState!.foodDiscount! /
                                    100;
                            addToCart(
                                widget.foodId,
                                foodSelected.foodName!,
                                quantity,
                                foodSelected.image!,
                                foodPrice,
                                foodSelected.foodType!);
                          },
                          child: Center(
                              child: Text(
                            "Thêm vào giỏ ",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: SpinKitWave(
        color: Colors.orange,
        size: 40,
      )),
    );
  }
}
