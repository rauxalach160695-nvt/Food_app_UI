import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  final List<types.Message> _messages = [
    types.TextMessage(
      author: types.User(id: '163'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'sdsdfsdfsdfsdfsdfsdfsdfsdfs',
      text: " ban co nghe toi noi gi khong?",
    )
  ];
  final _user = const types.User(id: '123');
  late bool _isLoading;

  Future<http.Response> chatBot(String userChat) async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {'sender': "thinhgnuyen", 'message': userChat};

    final response = await http.post(Uri.parse("${dotenv.env['API_BOT']}"),
        headers: headers, body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      var reply = jsonDecode(response.body)[0]['text'];
      types.TextMessage botReply = new types.TextMessage(
        author: types.User(id: '163'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: 'sdsdfsdfsdfsdfsdfsdfsdfsdfs',
        text: reply,
      );
      _messages.insert(0, botReply);
      setState(() {
        // debugger();
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
        body: SafeArea(
            child: Container(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text("data"), Text("data")],
                )))
        // Chat(
        //   messages: _messages,
        //   onSendPressed: _handleSendPressed,
        //   user: _user,
        //   bubbleBuilder: _bubbleBuilder,
        //   onAttachmentPressed: _handleImageSelection,
        // ),
        );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: randomString(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) =>
      Bubble(
        child: child,
        color: _user.id != message.author.id ||
                message.type == types.MessageType.image
            ? const Color(0xfff5f5f7)
            : Colors.orange,
        margin: nextMessageInGroup
            ? const BubbleEdges.symmetric(horizontal: 6)
            : null,
        nip: nextMessageInGroup
            ? BubbleNip.no
            : _user.id != message.author.id
                ? BubbleNip.leftBottom
                : BubbleNip.rightBottom,
      );

  void _addMessage(types.Message message) {
    _messages.insert(0, message);
    setState(() {});
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
    chatBot(message.text);
    debugPrint(_messages.toString());
  }
}
