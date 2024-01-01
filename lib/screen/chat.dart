import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:food_app/models/food_info_model.dart';
import 'package:food_app/screen/food_detail.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/message_model.dart' as ms;

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class Chat_screen extends StatefulWidget {
  const Chat_screen({super.key});

  @override
  State<Chat_screen> createState() => _Chat_screenState();
}

class _Chat_screenState extends State<Chat_screen> {
  List<FoodInfo> listFoodInfo = [];
  final List<types.TextMessage> _messages = [
    types.TextMessage(
      author: types.User(id: '163'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'sdsdfsdfsdfsdfsdfsdfsdfsdfs',
      text: " ban co nghe toi noi gi khong?",
    )
  ];
  List<ms.Message> messages = [
    // ms.Message(
    //     text: "hello",
    //     date: DateTime.now().subtract(Duration(minutes: 1)),
    //     isSentByMe: true,
    //     listFood: listFoodInfo
    //     ),

    // ms.Message(
    //     text: "in chao",
    //     date: DateTime.now().subtract(Duration(minutes: 1)),
    //     isSentByMe: false)
  ];

  final _user = const types.User(id: '123');
  late bool _isLoading;
  TextEditingController _chatController = new TextEditingController();

  Future<http.Response> chatBot(String userChat) async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {'sender': "thinhgnuyen", 'message': userChat};

    final response = await http.post(Uri.parse("${dotenv.env['API_BOT']}"),
        headers: headers, body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      var decodeText = jsonDecode(response.body)[0]['text'];
      var action = jsonDecode(decodeText)['action'];
      var reply;
      if (action == 'no') {
        reply = jsonDecode(decodeText)['Text'];
      } else {
        if (jsonDecode(decodeText)['listFood'].length < 1) {
          reply = "Không tìm thấy kết quả phù hợp.";
        } else {
          ms.Message botReply = new ms.Message(
              text: jsonDecode(decodeText)['Text'],
              date: DateTime.now(),
              isSentByMe: false,
              listFood: []);

          messages.add(botReply);
          List<dynamic> rawFood = jsonDecode(decodeText)['listFood'];
          listFoodInfo =
              rawFood.map((food) => FoodInfo.fromJson(food)).toList();
          debugger();
          reply = jsonDecode(decodeText)['Text'];
          List<FoodInfo> failFood = [];
          if (action == 'sale') {
            for (FoodInfo eachFood in listFoodInfo) {
              if (eachFood.foodInfoState!.length < 1) {
                failFood.add(eachFood);
              }
            }
          }
          for (FoodInfo eachFail in failFood) {
            listFoodInfo.removeWhere((element) => element == eachFail);
          }
          for (FoodInfo eachFood in listFoodInfo) {
            eachFood.price = (eachFood.price! -
                    eachFood.price! *
                        eachFood.foodInfoState![0].foodDiscount! /
                        100)
                .round() as int?;
          }
        }
      }

      ms.Message botReply = new ms.Message(
          text: reply,
          date: DateTime.now(),
          isSentByMe: false,
          listFood: listFoodInfo);

      messages.add(botReply);
      setState(() {
        // debugger();
        listFoodInfo = [];
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
    _isLoading = true;
    super.initState();
    // chatBot("chào");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: GroupedListView<ms.Message, DateTime>(
              padding: const EdgeInsets.all(8),
              reverse: true,
              order: GroupedListOrder.DESC,
              // useStickyGroupSeparators: true,
              // floatingHeader: true,
              elements: messages,
              groupBy: (message) => DateTime(
                  message.date.year, message.date.month, message.date.day),
              groupHeaderBuilder: (ms.Message message) => SizedBox(
                height: 40,
                child: Center(
                  child: Card(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(message.date),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, ms.Message message) => message
                          .listFood.length <
                      1
                  ? Align(
                      alignment: message.isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Card(
                        color:
                            message.isSentByMe ? Colors.orange : Colors.white,
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(message.text),
                        ),
                      ),
                    )
                  : Align(
                      alignment: message.isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        children: [
                          for (var i = 0; i < message.listFood.length; i++)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Food_detail(
                                            foodInfo: message.listFood[i])));
                              },
                              child: Card(
                                margin: EdgeInsets.only(right: 30, bottom: 10),
                                elevation: 8,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                                              image: DecorationImage(
                                                image: NetworkImage(message
                                                    .listFood[i].image
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
                                              padding: EdgeInsets.fromLTRB(
                                                  5, 0, 5, 0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: Text(
                                                message.listFood[i].foodName
                                                    .toString(),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  "${(message.listFood[i].price!).toStringAsFixed(3)}đ",
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
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            )),
            Container(
                color: Colors.grey,
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Type your message here....'),
                  onSubmitted: (text) {
                    final message = ms.Message(
                        date: DateTime.now(),
                        text: text,
                        isSentByMe: true,
                        listFood: listFoodInfo);
                    setState(() {
                      messages.add(message);
                      _chatController.text = '';
                      chatBot(text);
                    });
                  },
                ))
          ],
        )));
  }
}
