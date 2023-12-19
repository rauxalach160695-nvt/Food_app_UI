import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_app/screen/review.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/food_model.dart';

class Rating extends StatefulWidget {
  const Rating({
    super.key,
    required this.foodId,
  });

  final String foodId;

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  late bool _isLoading;
  late Food foodSelected;
  List<String> emojiText = [
    "Dở tệ",
    "Chưa ngon",
    "Cũng được",
    "Ngon",
    "Xuất sắc"
  ];
  num yourRating = 3;
  TextEditingController _ratingController = new TextEditingController();

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
    return response;
  }

  Future<http.Response> sendRating(String foodId) async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'foodId': foodId,
      'rate': yourRating,
      'comment': _ratingController.text
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/rate/addFoodRate"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        yourRating = 3;
        _ratingController.text = '';
        _isLoading = false;
        Navigator.pop(context);
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
    getFoodInfo(widget.foodId);
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
                          color: Colors.amber,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          foodSelected.rate!.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width - 60,
                          child: Divider(
                            color: Colors.orange,
                            height: 20,
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Center(
                          child: Text(
                        emojiText[yourRating.round() - 1],
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Center(
                        child: RatingBar.builder(
                            initialRating: 3,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4),
                            itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                yourRating = rating;
                              });
                            }),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _ratingController,
                          maxLines: 6,
                          maxLength: 200,
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.grey)),
                            hintText: "Viết đánh giá của bạn về món ăn...",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
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
                            sendRating(widget.foodId);
                          },
                          child: Center(
                              child: Text(
                            "Gửi",
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
