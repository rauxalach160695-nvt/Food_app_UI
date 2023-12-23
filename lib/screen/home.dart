import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/models/food_model.dart';
import 'package:food_app/models/user_info_model.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:food_app/screen/search.dart';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../models/food_info_model.dart';
import 'package:food_app/screen/loading_page.dart' as ld;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<FoodInfo> foods = [];
  TextEditingController _searchController = new TextEditingController();
  late bool _isLoading;
  late User_Info userInfo = new User_Info();
  String userName = '';

  Future<http.Response> getFoodByType() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'keyword': "cơm",
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/search/searchByType"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        debugPrint('chay day roi ');
        List<dynamic> rawFood = jsonDecode(response.body);
        // foods = rawFood.map((food) => Food.fromJson(food)).toList();
        foods = rawFood.map((food) => FoodInfo.fromJson(food)).toList();
        debugPrint(foods[1].image.toString());
        for (FoodInfo eachFood in foods) {
          eachFood.price = (eachFood.price! -
                  eachFood.price! *
                      eachFood.foodInfoState![0].foodDiscount! /
                      100)
              .round() as int?;
        }
        foods.sort((a, b) => a.price!.compareTo(b.price!));
        _isLoading = false;
      });
    } else {
      setState(() {
        debugPrint('run 111');
        _isLoading = true;
      });
    }
    // List<Food> foods = List<Food>.from(jsonDecode(response.body));
    return response;
  }

  Future<http.Response> getUserName() async {
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

        userName = userInfo.userName!;
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
    _isLoading = true;
    getFoodByType().then((value) => null);
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(vsync: this, length: 4);
    return _isLoading
        ? ld.LoadingPage()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: SafeArea(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Text(""),
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Chào mừng",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Image(
                              image: ResizeImage(
                                  AssetImage('images/icon_app.png'),
                                  width: 50,
                                  height: 50),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: const Text(
                        "Hôm nay bạn muốn ăn gì?",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Search(
                                        keyword: _searchController.text,
                                      )),
                            );
                            debugPrint(_searchController.text);
                          },
                          color: Colors.orange,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey)),
                        hintText: "Tìm kiếm món ăn...",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    height: 50,
                    width: double.maxFinite,
                    child: TabBar(
                      labelColor: Colors.orange,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.orange,
                      isScrollable: true,
                      controller: _tabController,
                      tabs: const [
                        Tab(
                          text: "Cơm",
                        ),
                        Tab(
                          text: "Món nước",
                        ),
                        Tab(
                          text: "Đồ ngọt",
                        ),
                        Tab(
                          text: "Đồ uống",
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 396,
                    width: double.infinity,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        GridView.count(
                          childAspectRatio: (7 / 11),
                          primary: false,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5,
                          crossAxisCount: 2,
                          children: <Widget>[
                            for (var i = 0; i < foods.length; i++)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Food_detail(
                                              foodInfo: foods[i],
                                            )),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  child: Column(children: [
                                    Container(
                                        height: 130,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            // border: Border.all(color: Colors.white),
                                            // color: Color.fromARGB(255, 255, 0, 0)
                                            // .withOpacity(0.5),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(foods[i].image!),
                                              fit: BoxFit.fitWidth,
                                            )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 20,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  "${(foods[i].price!).toStringAsFixed(3)}đ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            const SizedBox(
                                              height: 65,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    width: 50,
                                                    margin: EdgeInsets.only(
                                                        left: 10, top: 10),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 0, 5, 0),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          foods[i]
                                                              .rate
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.yellow,
                                                          size: 15,
                                                        )
                                                      ],
                                                    )),
                                                Container(
                                                  height: 30,
                                                  child: (foods[i]
                                                              .foodInfoState![0]
                                                              .foodDiscount ==
                                                          0)
                                                      ? Text("")
                                                      : Image(
                                                          image: AssetImage(
                                                              "images/sale.png")),
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                    Container(
                                      height: 90,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          // color: Colors.red,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)
                                                      .withOpacity(0.1),
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.white),
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              foods[i].foodName!.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              foods[i].description!.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                height: 1.5,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                        GridView.count(
                          childAspectRatio: (7 / 11),
                          primary: false,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5,
                          crossAxisCount: 2,
                          children: <Widget>[
                            for (var i = 0; i < foods.length; i++)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Food_detail(
                                              foodInfo: foods[i],
                                            )),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  child: Column(children: [
                                    Container(
                                        height: 130,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            // border: Border.all(color: Colors.white),
                                            // color: Color.fromARGB(255, 255, 0, 0)
                                            // .withOpacity(0.5),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(foods[i].image!),
                                              fit: BoxFit.fitWidth,
                                            )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 20,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  foods[i].price!.toString() +
                                                      ".000đ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            const SizedBox(
                                              height: 65,
                                            ),
                                            Container(
                                                height: 20,
                                                width: 50,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      foods[i].rate.toString(),
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.yellow,
                                                      size: 15,
                                                    )
                                                  ],
                                                ))
                                          ],
                                        )),
                                    Container(
                                      height: 90,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          // color: Colors.red,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)
                                                      .withOpacity(0.1),
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.white),
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              foods[i].foodName!.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              foods[i].description!.toString(),
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                        GridView.count(
                          childAspectRatio: (7 / 11),
                          primary: false,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5,
                          crossAxisCount: 2,
                          children: <Widget>[
                            for (var i = 0; i < foods.length; i++)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Food_detail(
                                              foodInfo: foods[i],
                                            )),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  child: Column(children: [
                                    Container(
                                        height: 130,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            // border: Border.all(color: Colors.white),
                                            // color: Color.fromARGB(255, 255, 0, 0)
                                            // .withOpacity(0.5),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(foods[i].image!),
                                              fit: BoxFit.fitWidth,
                                            )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 20,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  foods[i].price!.toString() +
                                                      ".000đ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            const SizedBox(
                                              height: 65,
                                            ),
                                            Container(
                                                height: 20,
                                                width: 50,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      foods[i].rate.toString(),
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.yellow,
                                                      size: 15,
                                                    )
                                                  ],
                                                ))
                                          ],
                                        )),
                                    Container(
                                      height: 90,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          // color: Colors.red,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)
                                                      .withOpacity(0.1),
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.white),
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              foods[i].foodName!.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              foods[i].description!.toString(),
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                        GridView.count(
                          childAspectRatio: (7 / 11),
                          primary: false,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5,
                          crossAxisCount: 2,
                          children: <Widget>[
                            for (var i = 0; i < foods.length; i++)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Food_detail(
                                              foodInfo: foods[i],
                                            )),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  child: Column(children: [
                                    Container(
                                        height: 130,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            // border: Border.all(color: Colors.white),
                                            // color: Color.fromARGB(255, 255, 0, 0)
                                            // .withOpacity(0.5),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(foods[i].image!),
                                              fit: BoxFit.fitWidth,
                                            )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 20,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  foods[i].price!.toString() +
                                                      ".000đ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            const SizedBox(
                                              height: 65,
                                            ),
                                            Container(
                                                height: 20,
                                                width: 50,
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      foods[i].rate.toString(),
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.yellow,
                                                      size: 15,
                                                    )
                                                  ],
                                                ))
                                          ],
                                        )),
                                    Container(
                                      height: 90,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          // color: Colors.red,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)
                                                      .withOpacity(0.1),
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.white),
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              foods[i].foodName!.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              foods[i].description!.toString(),
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ),
          );
  }
}
