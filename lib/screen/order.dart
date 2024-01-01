import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_app/screen/viewDetailOrder.dart';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../models/order_model.dart';
import '../models/food_info_model.dart' as predix;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/models/food_model.dart';
import 'package:food_app/models/rate_model.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:instant/instant.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  late bool _isLoading;
  List<UserOrder> listOrder = [];
  List<DateTime> listDate = [];

  Future<http.Response> getUserOrders() async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'token': await SessionManager().get('accessToken'),
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/order/viewAllOrder"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        var jsoncode = jsonDecode(response.body);
        for (var perOrder in jsoncode) {
          listOrder.add(UserOrder.fromJson(perOrder));
        }
        listOrder = listOrder.reversed.toList();
        for (var perOrder in listOrder) {
          DateTime perDate = DateTime.tryParse(perOrder.date!)!;
          listDate.add(DateTime(
              perDate.year - 1,
              perDate.day,
              perDate.month,
              perDate.hour + 7,
              perDate.minute,
              perDate.second,
              perDate.microsecond));
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

  Future<http.Response> deleteOrder(int id) async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'orderId': listOrder[id].sId.toString()
    };

    final response = await http.put(
        Uri.parse("${dotenv.env['API_HOST']}/order/deleteOrderFromUser"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        debugPrint("delete success");
        listDate.removeWhere((item) => item == listDate[id]);
        listOrder.removeWhere((item) => item.sId == listOrder[id].sId);
        Navigator.pop(context, 'OK');
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
    super.initState();
    _isLoading = true;
    getUserOrders();
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
              child: Column(
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
                                MaterialStateProperty.all<Color>(Colors.white),
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
                              "Đơn Hàng",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ),
                        )),
                  ]),
                  (listOrder.length < 1)
                      ? Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                              ),
                              Icon(
                                Icons.receipt_long_outlined,
                                color: Colors.grey,
                                size: 200,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Hiện tại không có lịch sử mua nào",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              )
                            ],
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height - 102,
                          margin: EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                          ),
                          child: GridView.count(
                            childAspectRatio: (8 / 4),
                            primary: false,
                            padding: const EdgeInsets.all(15),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 20,
                            crossAxisCount: 1,
                            children: <Widget>[
                              for (var i = 0; i < listOrder.length; i++)
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
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            4.0, 4.0),
                                                        blurRadius: 15,
                                                        spreadRadius: 1.0),
                                                    const BoxShadow(
                                                        color: Colors.white,
                                                        offset:
                                                            Offset(-4.0, -4.0),
                                                        blurRadius: 15,
                                                        spreadRadius: 1.0)
                                                  ],
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          listOrder[i]
                                                              .image
                                                              .toString()),
                                                      fit: BoxFit.fitWidth)),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "  ${DateFormat('dd/MM/yyyy kk:mm').format(listDate[i])}",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${listOrder[i].cost!.toStringAsFixed(3)}đ",
                                                    style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  RichText(
                                                      text: TextSpan(children: [
                                                    WidgetSpan(
                                                        child: (listOrder[i]
                                                                    .orderState ==
                                                                1)
                                                            ? Icon(
                                                                Icons
                                                                    .radio_button_checked,
                                                                color: Colors
                                                                    .green,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .outdoor_grill,
                                                                color: Colors
                                                                    .redAccent,
                                                              )),
                                                    (listOrder[i].orderState ==
                                                            1)
                                                        ? TextSpan(
                                                            text: "  Đã giao",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                            ))
                                                        : TextSpan(
                                                            text:
                                                                "  Đang chuẩn bị",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .redAccent,
                                                            ),
                                                          )
                                                  ]))
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Center(
                                              child: Container(
                                                height: 40,
                                                width: 130,
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Colors.orange),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      50),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .orange)))),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewDetailOrder(
                                                                    order:
                                                                        listOrder[
                                                                            i],
                                                                    date: listDate[
                                                                        i])));
                                                  },
                                                  child: Center(
                                                      child: Text(
                                                    "xem chi tiết",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                height: 40,
                                                width: 130,
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      foregroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              const Color.fromARGB(
                                                                  255, 255, 0, 0)),
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Colors.white),
                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(50),
                                                              side: BorderSide(color: Colors.white)))),
                                                  onPressed: () {
                                                    deleteOrderDialog(i);
                                                  },
                                                  child: Center(
                                                      child: Text(
                                                    "Xóa đơn",
                                                    style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 15),
                                                  )),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                ],
              ),
            ));
  }

  Future deleteOrderDialog(int i) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Bạn có chắc muốn xóa"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    debugPrint(i.toString());
                    deleteOrder(i);
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ));
}
