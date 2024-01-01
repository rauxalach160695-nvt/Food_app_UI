import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../models/food_info_model.dart' as predix;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/models/food_model.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import '../models/user_info_model.dart';

class Search extends StatefulWidget {
  const Search({super.key, required this.keyword});

  final String keyword;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = new TextEditingController();
  String searchWord = "";
  List<predix.FoodInfo> foods = [];
  late bool _isLoading;
  int sortState = 0;

  Future<http.Response> getFoodByName(String keyword) async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'keyword': keyword,
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/search/searchByName"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        // List<dynamic> rawFood = jsonDecode(response.body)["findFood"];
        List<dynamic> rawFood = jsonDecode(response.body);
        foods = rawFood.map((food) => predix.FoodInfo.fromJson(food)).toList();
        for (predix.FoodInfo eachFood in foods) {
          eachFood.price = (eachFood.price! -
                  eachFood.price! *
                      eachFood.foodInfoState![0].foodDiscount! /
                      100)
              .round() as int?;
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        debugPrint('run 111');
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
    getFoodByName(widget.keyword);
    searchWord = widget.keyword;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              getFoodByName(_searchController.text);
                              setState(() {
                                searchWord = _searchController.text;
                                debugPrint(widget.keyword);
                              });
                            },
                            color: Colors.orange,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey)),
                          hintText: "Tìm kiếm món ăn...",
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Text(
                      "Kết quả cho" + " " + ' " ' + searchWord + ' " ',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 300,
                        ),
                        Material(
                            type: MaterialType
                                .transparency, //Makes it usable on any background color, thanks @IanSmith
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                //This keeps the splash effect within the circle
                                borderRadius: BorderRadius.circular(
                                    10.0), //Something large to ensure a circle
                                onTap: () {
                                  setState(() {
                                    if (sortState == 0) {
                                      foods.sort((a, b) =>
                                          a.price!.compareTo(b.price!));
                                      sortState = 1;
                                    } else {
                                      foods = foods.reversed.toList();
                                      sortState = 0;
                                    }
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Icon(
                                    Icons.local_atm,
                                    size: 30.0,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 550,
                    child: GridView.count(
                      childAspectRatio: (10 / 8),
                      primary: false,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 5,
                      crossAxisCount: 1,
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
                                        borderRadius: BorderRadius.circular(15),
                                        // border: Border.all(color: Colors.white),
                                        // color: Color.fromARGB(255, 255, 0, 0)
                                        // .withOpacity(0.5),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              foods[i].image.toString()),
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
                                            padding:
                                                EdgeInsets.fromLTRB(5, 0, 5, 0),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              foods[i]
                                                      .price!
                                                      .toStringAsFixed(3) +
                                                  "đ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        const SizedBox(
                                          height: 65,
                                        ),
                                        Container(
                                            height: 20,
                                            width: 50,
                                            margin: EdgeInsets.only(
                                                left: 10, top: 10),
                                            padding:
                                                EdgeInsets.fromLTRB(5, 0, 5, 0),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
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
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          foods[i].foodName.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          foods[i].description.toString(),
                                          style: TextStyle(
                                              color: Colors.grey,
                                              overflow: TextOverflow.ellipsis),
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
                  )
                ],
              ),
            )),
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
