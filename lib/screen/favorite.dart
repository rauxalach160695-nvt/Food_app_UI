import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:food_app/models/food_info_model.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:food_app/screen/nav_screen.dart';
import '../models/user_info_model.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key, required this.userInfo});

  final User_Info userInfo;

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  late bool _isLoading;
  List<FoodInfo> foods = [];

  Future<http.Response> getFavoriteFood() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, List<String>> jsonBody = {
      'favoriteFood': widget.userInfo.favoriteFood!,
    };
    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/food/getFavorite"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        debugPrint('chay day roi ');
        List<dynamic> rawFood = jsonDecode(response.body);
        // foods = rawFood.map((food) => Food.fromJson(food)).toList();
        foods = rawFood.map((food) => FoodInfo.fromJson(food)).toList();
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

  Future<http.Response> updateFavorite(int index) async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'foodId': foods[index].sId,
      'check': false
    };

    final response = await http.put(
        Uri.parse("${dotenv.env['API_HOST']}/user/editFavorite"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        foods.removeWhere((element) => element == foods[index]);
        widget.userInfo.favoriteFood!.removeWhere(
            (element) => element == widget.userInfo.favoriteFood![index]);
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
    getFavoriteFood();
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
                              "Món Ghiền",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ),
                        )),
                  ]),
                  (widget.userInfo.favoriteFood!.length < 1)
                      ? Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 80,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 100,
                                child: Image(
                                  image: AssetImage('images/foodNotFound.png'),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Chưa có món yêu thích nào",
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
                          width: MediaQuery.of(context).size.width + 300,
                          child: GridView.count(
                            childAspectRatio: (7 / 11),
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 5,
                            crossAxisCount: 2,
                            children: <Widget>[
                              for (var i = 0;
                                  i < widget.userInfo.favoriteFood!.length;
                                  i++)
                                InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => Food_detail(
                                    //             foodInfo: foods[i],
                                    //           )),
                                    // );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    child: Column(children: [
                                      Slidable(
                                        endActionPane: ActionPane(
                                            motion: StretchMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {
                                                  updateFavorite(i);
                                                },
                                                icon: Icons.thumb_down_alt,
                                                backgroundColor: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              )
                                            ]),
                                        child: Container(
                                            height: 130,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                // border: Border.all(color: Colors.white),
                                                // color: Color.fromARGB(255, 255, 0, 0)
                                                // .withOpacity(0.5),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      foods[i].image!),
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
                                                        EdgeInsets.fromLTRB(
                                                            5, 0, 5, 0),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
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
                                                                    .circular(
                                                                        50)),
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
                                                              color:
                                                                  Colors.yellow,
                                                              size: 15,
                                                            )
                                                          ],
                                                        )),
                                                    Container(
                                                      height: 30,
                                                      child: (foods[i]
                                                                  .foodInfoState![
                                                                      0]
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
                                      ),
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
                                                bottomRight:
                                                    Radius.circular(10)),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                foods[i]
                                                    .description!
                                                    .toString(),
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
                        ),
                ],
              ),
            ));
    ;
  }
}
