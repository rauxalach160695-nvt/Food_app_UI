import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/models/cart_model.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:food_app/screen/review.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/food_model.dart';
import 'package:food_app/screen/edit_profile.dart';
import 'package:food_app/screen/default.dart';
import 'package:food_app/screen/order.dart';
import 'package:food_app/screen/favorite.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
import '../models/user_info_model.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late bool _isLoading;
  late User_Info userInfo = new User_Info();

  Future<void> logOut() async {
    await SessionManager().set("accessToken", '');
    await SessionManager().set("cart", List_cart(cart: []));
    Navigator.push(context, MaterialPageRoute(builder: (context) => Default()));
  }

  Future<http.Response> getUserInfo() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/user/getuserInfo"),
        headers: headers,
        body: jsonEncode(jsonBody));

    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);
        var dataconvert = User_Info.fromJson(data[0]);
        userInfo = dataconvert;
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
    getUserInfo();
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
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 90,
                    ),
                    Center(
                      child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade500,
                                  offset: const Offset(4.0, 4.0),
                                  blurRadius: 15,
                                  spreadRadius: 1.0),
                              const BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4.0, -4.0),
                                  blurRadius: 15,
                                  spreadRadius: 1.0),
                            ],
                            image: DecorationImage(
                                image: AssetImage(
                                    'images/avatar_${userInfo.avatarNum}.jpg'),
                                fit: BoxFit.fitWidth),
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      userInfo.userName.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.grey,
                              size: 15,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              userInfo.phoneNumber.toString(),
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    // Divider(
                    //   color: Colors.grey,
                    //   thickness: 1,
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 100,
                                width:
                                    (MediaQuery.of(context).size.width - 60) /
                                        2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 0, 0, 0)
                                            .withOpacity(0.1),
                                        offset: const Offset(4, 4),
                                        spreadRadius: 4)
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Favorite(userInfo: userInfo)));
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.pinkAccent,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        Icons.favorite_border_outlined,
                                        color: Colors.pinkAccent,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Món Ghiền",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 100,
                                width:
                                    (MediaQuery.of(context).size.width - 60) /
                                        2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  // border: Border.all(color: Colors.orange),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 0, 0, 0)
                                            .withOpacity(0.1),
                                        offset: const Offset(4, 5),
                                        spreadRadius: 3)
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Order()));
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.brown,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: Colors.brown,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Đơn Hàng",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 110,
                            width: (MediaQuery.of(context).size.width - 60) / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              // border: Border.all(color: Colors.orange),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromARGB(255, 0, 0, 0)
                                        .withOpacity(0.1),
                                    offset: const Offset(4, 5),
                                    spreadRadius: 3)
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile(
                                            userInfo: userInfo,
                                          )),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Icon(
                                    Icons.settings,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Chỉnh Sửa Thông Tin Cá Nhân",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Container(
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          logOut();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.pinkAccent,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Icon(
                              Icons.power_settings_new_outlined,
                              color: Colors.redAccent,
                              size: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Đăng Xuất",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
