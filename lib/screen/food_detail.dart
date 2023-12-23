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
import '../models/food_info_model.dart';
import '../models/user_info_model.dart';

import 'package:uuid/uuid.dart';

class Food_detail extends StatefulWidget {
  const Food_detail({
    super.key,
    required this.foodInfo,
  });

  final FoodInfo foodInfo;

  @override
  State<Food_detail> createState() => _Food_detailState();
}

class _Food_detailState extends State<Food_detail> {
  late bool _isLoading = false;
  final LocalStorage storage = new LocalStorage('cart.json');
  var quantity = 1;
  var uuid = Uuid();
  late User_Info userInfo;
  bool favorite = false;

  Future<http.Response> getUserInfo() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'token': await SessionManager().get('accessToken'),
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/user/getUserInfo"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        var jsonData = jsonDecode(response.body);
        userInfo = User_Info.fromJson(jsonData[0]);
        for (var item in userInfo.favoriteFood!) {
          if (item == widget.foodInfo.sId) {
            favorite = true;
          }
        }

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    return response;
  }

  Future<http.Response> updateFavorite() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'foodId': widget.foodInfo.sId,
      'check': favorite
    };

    final response = await http.put(
        Uri.parse("${dotenv.env['API_HOST']}/user/editFavorite"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    return response;
  }

  Future<void> addToCart(String foodId, String name, int quantity, String image,
      num price, List<String> type) async {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
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
                              image: NetworkImage(widget.foodInfo.image!),
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
                        widget.foodInfo.foodName!,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.foodInfo.rate.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Review(
                                            foodInfo: widget.foodInfo,
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
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      favorite = !favorite;
                                      updateFavorite();
                                    });
                                  },
                                  child: favorite
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.pinkAccent,
                                        )
                                      : Icon(
                                          Icons.favorite_border_outlined,
                                          color: Colors.pinkAccent,
                                        )),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // "${(widget.foodInfo.price! - widget.foodInfo.price! * num.parse((widget.foodInfo.foodInfoState![0].foodDiscount).toString()) / 100).toStringAsFixed(3)}đ",
                              "${(widget.foodInfo.price!).toStringAsFixed(3)}đ",
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
                        widget.foodInfo.description.toString(),
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
                            double foodPrice = widget.foodInfo.price! -
                                widget.foodInfo.price! *
                                    widget.foodInfo.foodInfoState![0]
                                        .foodDiscount! /
                                    100;
                            addToCart(
                                widget.foodInfo.sId!,
                                widget.foodInfo.foodName!,
                                quantity,
                                widget.foodInfo.image!,
                                widget.foodInfo.price!,
                                widget.foodInfo.foodType!);
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
