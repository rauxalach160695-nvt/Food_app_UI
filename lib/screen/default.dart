import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:food_app/screen/login.dart';
import 'package:food_app/screen/signup.dart';
import "dart:convert";

class Default extends StatefulWidget {
  const Default({super.key});

  @override
  State<Default> createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  bool pressed = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0),
            image: DecorationImage(
                image: AssetImage('images/default_screen.jpg'),
                fit: BoxFit.cover,
                opacity: 0.8),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FractionallySizedBox(
              widthFactor: 1,
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Chào mừng bạn đến với',
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                )),
            Container(
              padding: const EdgeInsets.all(15),
              child: const Text(
                'JuicyFood',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 280,
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: const Row(children: [
                Expanded(
                    child: Divider(
                  color: Colors.white,
                  thickness: 1,
                )),
                SizedBox(width: 10),
                Text(
                  'Đăng nhập ngay',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Expanded(
                    child: Divider(
                  color: Colors.white,
                  thickness: 1,
                )),
              ]),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Signup()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.white;
                    }
                    return Colors.black.withOpacity(0.5);
                  }),
                  side: MaterialStateProperty.resolveWith((states) {
                    Color borderColor;

                    if (states.contains(MaterialState.disabled)) {
                      borderColor = const Color.fromARGB(255, 255, 255, 255);
                    } else if (states.contains(MaterialState.pressed)) {
                      borderColor = const Color.fromARGB(255, 255, 255, 255);
                    } else {
                      borderColor = const Color.fromARGB(255, 255, 255, 255);
                    }
                    return BorderSide(color: borderColor, width: 1);
                  }),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                ),
                child: const SizedBox(
                  width: 500,
                  height: 50,
                  child: Center(
                    child: Text(
                      'Bắt đầu bằng số điện thoại',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: [
                  const SizedBox(width: 50),
                  const Text(
                    'Bạn đã có tài khoản? ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    child: Text(
                      'Đăng nhập',
                      style: pressed
                          ? const TextStyle(
                              color: Colors.orange, fontWeight: FontWeight.bold)
                          : const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      parseJson();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                      setState(() {
                        pressed = !pressed;
                      });
                    },
                  )
                ],
              ),
            )
          ]),
        ),
      )),
    );
  }

  void parseJson() {
    final testparse = json.decode(
        "{\"link\": \"google.com\", \"Text\": \"B\\u1ea1n c\\u00f3 th\\u1ec3 th\\u1eed nh\\u1eefng m\\u00f3n l\\u1ea9u hay s\\u00fap m\\u1edbi c\\u1ee7a c\\u1eeda h\\u00e0ng\"}");

    debugPrint(testparse.toString());
  }
}
