import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:food_app/screen/rating.dart';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../models/food_info_model.dart' as predix;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/models/food_info_model.dart';
import 'package:food_app/models/rate_model.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';

class Review extends StatefulWidget {
  const Review({
    super.key,
    required this.foodInfo,
  });

  final FoodInfo foodInfo;

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  late bool _isLoading;
  List<Rate> listRating = [];

  Future<http.Response> getFoodRate(String id) async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'foodId': id,
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/rate/viewFoodRate"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        var jsoncode = jsonDecode(response.body);
        for (var perRate in jsoncode) {
          listRating.add(Rate.fromJson(perRate));
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    getFoodRate(widget.foodInfo.sId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        : Scaffold(
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
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.only(right: 50),
                            child: Text(
                              "Đánh giá",
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Rating(
                                  foodInfo: widget.foodInfo,
                                )),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: 320,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                    image: AssetImage('images/avatar.png'),
                                    fit: BoxFit.fitWidth),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Viết đánh giá của bạn...")
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    child: Column(
                      children: [
                        for (var i = 0; i < listRating.length; i++)
                          Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          height: 50,
                                          width: 50,
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            height: 23,
                                            width: 23,
                                            decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius:
                                                    BorderRadius.circular(80)),
                                            child: Center(
                                              child: Text(
                                                listRating[i]
                                                    .rate!
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/avatar.png'),
                                                fit: BoxFit.fitWidth),
                                          )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listRating[i]
                                                .userInfo![0]
                                                .userName
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "  ${DateFormat('dd/MM/yyyy').format(DateTime.tryParse(listRating[i].date!)!)}",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      listRating[i].comment.toString(),
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 112, 112, 112)),
                                    ),
                                  )
                                ],
                              ))
                      ],
                    ),
                  )
                ],
              ),
            )),
          );
    ;
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
