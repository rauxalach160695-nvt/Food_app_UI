import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import "../models/order_model.dart";
import '../models/cart_model.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
import 'package:flutter_session_manager/flutter_session_manager.dart';

class ViewDetailOrder extends StatefulWidget {
  const ViewDetailOrder({super.key, required this.order, required this.date});

  final UserOrder order;
  final DateTime date;

  @override
  State<ViewDetailOrder> createState() => _ViewDetailOrderState();
}

class _ViewDetailOrderState extends State<ViewDetailOrder> {
  late bool _isLoading;
  List<OrderDetail> listOrderDetail = [];
  var uuid = Uuid();

  Future<http.Response> viewOrderDetail() async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'orderId': widget.order.sId.toString()
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/order/viewOrder"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    debugPrint(widget.order.sId.toString());
    if (response.statusCode == 200) {
      setState(() {
        var jsoncode = jsonDecode(response.body);
        for (var perOrderDetail in jsoncode) {
          listOrderDetail.add(OrderDetail.fromJson(perOrderDetail));
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

  Future<void> reBuy() async {
    _isLoading = true;
    var listCart = await SessionManager().get('cart');
    if (listCart != null) {
      List_cart list_local =
          List_cart.fromJson(await SessionManager().get("cart"));
      for (var eachCart in listOrderDetail) {
        String codeHiding = uuid.v4();
        num? currentPrice = eachCart.foodInfomation![0].price! -
            eachCart.foodInfomation![0].price! *
                num.parse((eachCart
                    .foodInfomation![0].stateFood![0].foodDiscount
                    .toString())) /
                100;
        Cart item = new Cart(
            id: eachCart.foodId,
            name: eachCart.foodInfomation![0].foodName,
            quantity: eachCart.quantity,
            image: eachCart.foodInfomation![0].image,
            price: currentPrice,
            type: eachCart.foodInfomation![0].foodType,
            idcart: codeHiding);
        list_local.cart?.add(item);
      }
      SessionManager().set("cart", list_local);
      setState(() {
        _isLoading = false;
      });
    } else {
      List_cart list_local =
          List_cart.fromJson(await SessionManager().get("cart"));
      for (var eachCart in listOrderDetail) {
        String codeHiding = uuid.v4();
        num? currentPrice = eachCart.foodInfomation![0].price! -
            eachCart.foodInfomation![0].price! *
                num.parse((eachCart
                    .foodInfomation![0].stateFood![0].foodDiscount
                    .toString())) /
                100;
        Cart item = new Cart(
            id: eachCart.foodId,
            name: eachCart.foodInfomation![0].foodName,
            quantity: eachCart.quantity,
            image: eachCart.foodInfomation![0].image,
            price: currentPrice,
            type: eachCart.foodInfomation![0].foodType,
            idcart: codeHiding);
        list_local.cart?.add(item);
      }
      SessionManager().set("cart", list_local);
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
    _isLoading = false;
    viewOrderDetail();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? ld.LoadingPage()
        : Scaffold(
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.orange,
                child: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Navigation(selectedIndex: 1)));
                }),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(children: [
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
                                        borderRadius: BorderRadius.circular(10),
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
                        Container(
                            width: 270,
                            height: 50,
                            margin: EdgeInsets.only(left: 15, top: 10),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.only(right: 50),
                                child: Text(
                                  "Thông Tin Đơn Hàng",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ),
                              ),
                            )),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 50,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Địa chỉ giao hàng",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 100,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.orange),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    side: BorderSide(
                                                        color:
                                                            Colors.orange)))),
                                        onPressed: () {
                                          reBuy();
                                        },
                                        child: Center(
                                            child: Text(
                                          "Mua lại",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width - 50,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.order.address.toString(),
                                    style: TextStyle(color: Colors.grey),
                                  ))
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width - 80,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ngày đặt hàng",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "  ${DateFormat('dd/MM/yyyy kk:mm').format(widget.date)}",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Giá tiền",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "  ${widget.order.cost!.toStringAsFixed(3)}đ",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Trạng thái",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    (widget.order.orderState == 1)
                                        ? "Đã giao"
                                        : "Đang chuẩn bị",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < listOrderDetail.length; i++)
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              width: MediaQuery.of(context).size.width - 50,
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
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                listOrderDetail[i]
                                                    .foodInfomation![0]
                                                    .image
                                                    .toString()),
                                            fit: BoxFit.fitWidth,
                                          )),
                                      child: Text("")),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: 200,
                                          height: 50,
                                          margin: EdgeInsets.only(left: 10),
                                          padding:
                                              EdgeInsets.fromLTRB(5, 0, 5, 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Text(
                                            listOrderDetail[i]
                                                .foodInfomation![0]
                                                .foodName
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          )),
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
                                              "${(listOrderDetail[i].priceNow!).toStringAsFixed(3)}đ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                                                Text(
                                                  "số lượng:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(width: 10),
                                                Container(
                                                  width: 25,
                                                  child: Center(
                                                    child: Text(
                                                      listOrderDetail[i]
                                                          .quantity
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
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
                      )
                    ],
                  ),
                ),
              ),
            ));
    ;
  }
}
