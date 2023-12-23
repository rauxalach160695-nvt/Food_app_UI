import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/screen/checkout.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import '../models/cart_model.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart';
import 'package:geocode/geocode.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
// import 'package:geocoding/geocoding.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final LocalStorage storage = new LocalStorage('cart.json');
  late List_cart list = List_cart(cart: []);
  late List_cart list_local = List_cart(cart: []);
  late bool _isLoading;
  String address = "Địa chỉ giao hàng....";
  TextEditingController _addressController = new TextEditingController();
  double sumPrice = 0;
  GeoCode geoCode = GeoCode();
  var uuid = Uuid();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    getCart();
    getUserAddress();
  }

  Future<void> getCart() async {
    debugPrint((await SessionManager().get("cart")).toString());
    if (await SessionManager().get("cart") != null) {
      list_local = List_cart.fromJson(await SessionManager().get("cart"));
      setState(() {
        _isLoading = false;
        list = list_local;
        for (var item in list.cart!) {
          sumPrice += (item.price! * item.quantity!);
        }
      });
      debugPrint(list.toJson().toString());
      debugPrint(_isLoading.toString());
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    debugPrint(list.toJson().toString());
    debugPrint(list.cart!.length.toString());
    // debugPrint(list.cart![1].name);
  }

  Future<void> orderFood() async {
    if (list.cart!.length > 0) {
      sendData();
    } else {
      debugPrint("You dont have food in cart!!!!!");
    }
  }

  Future<void> clearList() async {
    await SessionManager().set('cart', List_cart(cart: []));
  }

  Future<void> updateList() async {
    await SessionManager().set('cart', list);
  }

  Future<http.Response> sendData() async {
    int cost = sumPrice.round() + 5;
    debugPrint(cost.toString());
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'listCart': list,
      'cost': cost,
      'orderState': 0,
      'image': list.cart![0].image,
      'address': address,
      'userViewAble': true
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/order/addOrder"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        sumPrice = 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    await SessionManager().set('cart', List_cart(cart: []));
    setState(() {
      list = List_cart(cart: []);
    });
    // List<Food> foods = List<Food>.from(jsonDecode(response.body));
    return response;
  }

  Future<http.Response> getUserAddress() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'token': await SessionManager().get('accessToken'),
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/user/getUserAddress"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        address = json.decode(response.body)["userAddress"];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    return response;
  }

  getUserLocation() async {
    //call this async method from whereever you need

    LocationData? myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    debugPrint(myLocation!.longitude.toString());
    debugPrint("??????????");
    var addressFind = await geoCode.reverseGeocoding(
        latitude: 16.0754348, longitude: 108.1474478);
    Coordinates coordinates = await geoCode.forwardGeocoding(
        address:
            "106A Nguyễn Lương Bằng, Hoà Khánh Bắc, Liên Chiểu, Đà Nẵng 550000, Việt Nam");
    debugPrint(coordinates.latitude.toString());
    // debugger();
    debugPrint(addressFind.streetNumber.toString() +
        " " +
        addressFind.streetAddress.toString() +
        " " +
        addressFind.region.toString() +
        " " +
        addressFind.countryName.toString());
    return location;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? ld.LoadingPage()
        : Scaffold(
            appBar: AppBar(
              title: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    width: MediaQuery.of(context).size.width - 100,
                    child: Text(
                      address,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        changeAddress();
                      },
                      child: Icon(
                        Icons.edit_document,
                        color: Colors.white,
                      ))
                ],
              )),
              backgroundColor: Colors.orange,
              automaticallyImplyLeading: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: list.cart!.length < 1
                ? SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                              width: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                // border: Border.all(color: Colors.white),
                                // color: Color.fromARGB(255, 255, 0, 0)
                                // .withOpacity(0.5),
                              ),
                              child: Image(
                                image: AssetImage("images/xianglingcook.png"),
                                fit: BoxFit.fitWidth,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Bạn chưa có món nào trong giỏ @@",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 350,
                          child: GridView.count(
                            childAspectRatio: (7 / 2),
                            primary: false,
                            padding: const EdgeInsets.all(15),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 5,
                            crossAxisCount: 1,
                            children: <Widget>[
                              for (var i = 0; i < list.cart!.length; i++)
                                Container(
                                  decoration: BoxDecoration(
                                      // color: Colors.red,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromARGB(255, 0, 0, 0)
                                              .withOpacity(0.1),
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      // border: Border.all(color: Colors.white),
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              // border: Border.all(color: Colors.white),
                                              // color: Color.fromARGB(255, 255, 0, 0)
                                              // .withOpacity(0.5),
                                              image: DecorationImage(
                                                image: NetworkImage(list
                                                    .cart![i].image
                                                    .toString()),
                                                fit: BoxFit.fitWidth,
                                              )),
                                          child: Text("")),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      width: 100,
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              5, 0, 5, 0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                      ),
                                                      child: Text(
                                                        list.cart![i].name
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                  // SizedBox(
                                                  //   height: 5,
                                                  // ),
                                                  // Container(
                                                  //   height: 20,
                                                  //   margin: EdgeInsets.only(
                                                  //     left: 10,
                                                  //   ),
                                                  //   padding:
                                                  //       EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                  //   decoration: BoxDecoration(
                                                  //       color: Colors.white,
                                                  //       borderRadius:
                                                  //           BorderRadius.circular(50)),
                                                  //   child: Text(
                                                  //     "Cơm" + ",   " + "Bò",
                                                  //     style: TextStyle(
                                                  //         fontSize: 15,
                                                  //         color: Colors.grey),
                                                  //   ),
                                                  // )
                                                ],
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 70),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.orange,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      sumPrice -=
                                                          list.cart![i].price! *
                                                              list.cart![i]
                                                                  .quantity!;
                                                      list.cart!.removeWhere(
                                                          (item) =>
                                                              item.idcart ==
                                                              list.cart![i]
                                                                  .idcart);
                                                      updateList();
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                width: 70,
                                                child: Text(
                                                  list.cart![i].price!
                                                          .toStringAsFixed(3) +
                                                      'đ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.orange),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 35,
                                                      width: 35,
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(Colors
                                                                        .white),
                                                            shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                    side: BorderSide(
                                                                        color: Colors.orange)))),
                                                        onPressed: () {
                                                          if (list.cart![i]
                                                                  .quantity! >=
                                                              2) {
                                                            setState(() {
                                                              sumPrice -= list
                                                                  .cart![i]
                                                                  .price!;
                                                              list.cart![i]
                                                                  .quantity = (list
                                                                      .cart![i]
                                                                      .quantity! -
                                                                  1);
                                                            });
                                                          }
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.remove,
                                                          size: 7,
                                                          color: Colors.orange,
                                                        )),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width: 25,
                                                      child: Center(
                                                        child: Text(
                                                          list.cart![i].quantity
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      height: 35,
                                                      width: 35,
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(Colors
                                                                        .orange),
                                                            shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                    side: BorderSide(
                                                                        color: Colors.orange)))),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (list.cart![i]
                                                                    .quantity! <=
                                                                99) {
                                                              setState(() {
                                                                sumPrice += list
                                                                    .cart![i]
                                                                    .price!;
                                                                list.cart![i]
                                                                    .quantity = list
                                                                        .cart![
                                                                            i]
                                                                        .quantity! +
                                                                    1;
                                                              });
                                                            }
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.add,
                                                          size: 7,
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
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Tiền món ăn ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    sumPrice.toStringAsFixed(3) + "đ",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(color: Colors.grey),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Phí vận chuyển",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "5.000đ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(color: Colors.grey),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tổng tiền",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    (sumPrice + 5).toStringAsFixed(3) + "đ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            child: Center(
                          child: Container(
                            height: 50,
                            width: 200,
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
                                // orderFood();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CheckoutPage()));
                              },
                              child: Center(
                                  child: Text(
                                "Đặt đơn",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ));
  }

  Future changeAddress() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Địa chỉ giao hàng"),
            content: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: "Nhập địa chỉ...",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    address = _addressController.text;
                    Navigator.pop(context, 'OK');
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ));
}
