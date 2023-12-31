import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:food_app/screen/signup.dart';
import "dart:convert";
import 'package:food_app/screen/default.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_app/screen/home.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  var _signInErr = "Số điện thoại hoặc mật khẩu không đúng";
  var _passwordVisible;
  var _signInInvalid = false;
  late bool _isLoading;
  late bool _error;
  late String _errorMessage;
  bool pressed = true;

  @override
  void initState() {
    _passwordVisible = true;
    _phoneController.text = '0905567874';
    _passController.text = '12345678';
    _isLoading = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<http.Response> loginRequest() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'phoneNumber': _phoneController.text,
      'password': _passController.text,
    };

    final response = await http.post(
        Uri.parse("${dotenv.env['API_HOST']}/user/signIn"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = !_isLoading;
        _error = false;
        debugPrint('chay day roi ');
      });
      await SessionManager()
          .set("accessToken", json.decode(response.body)['token']);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Navigation(
                    selectedIndex: 0,
                  )));
    } else {
      setState(() {
        _isLoading = !_isLoading;
        _error = true;
        // _errorMessage = json.decode(response.body)['message'];
        _errorMessage = "wrong";
        _signInInvalid = true;
        debugPrint('run 111');
      });
    }
    debugPrint(response.body);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        // constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          reverse: true,
          // decoration: const BoxDecoration(
          //   color: Color.fromARGB(255, 0, 0, 0),
          //   image: DecorationImage(
          //       image: AssetImage('images/auth_base.png'),
          //       fit: BoxFit.cover,
          //       opacity: 1),
          // ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const FractionallySizedBox(
                //   widthFactor: 1,
                // ),
                Container(
                  child: const Image(image: AssetImage('images/head_auth.png')),
                ),
                Container(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    )),
                Container(
                  margin: const EdgeInsets.all(15),
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(color: Colors.grey)),
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey)),
                        hintText: "Số điện thoại",
                        errorText: _signInInvalid ? _signInErr : null,
                        labelText: "Số điện thoại"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(color: Colors.grey)),
                  child: TextField(
                    controller: _passController,
                    obscureText: _passwordVisible,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey)),
                      hintText: "Mật khẩu",
                      labelText: "Mật khẩu",
                      suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          }),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  child: OutlinedButton(
                    onPressed: () {
                      onLoginClick();
                      loginRequest();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.white;
                        }
                        return Colors.orange;
                      }),
                      side: MaterialStateProperty.resolveWith((states) {
                        Color borderColor;

                        if (states.contains(MaterialState.disabled)) {
                          borderColor =
                              const Color.fromARGB(255, 255, 255, 255);
                        } else if (states.contains(MaterialState.pressed)) {
                          borderColor =
                              const Color.fromARGB(255, 255, 255, 255);
                        } else {
                          borderColor =
                              const Color.fromARGB(255, 255, 255, 255);
                        }
                        return BorderSide(color: borderColor, width: 1);
                      }),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                    ),
                    child: const SizedBox(
                      width: 500,
                      height: 60,
                      child: Center(
                        child: Text(
                          'Đăng nhập',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    children: [
                      const SizedBox(width: 50),
                      const Text(
                        'Bạn chưa có tài khoản? ',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        child: Text(
                          'Đăng Ký',
                          style: pressed
                              ? const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)
                              : const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Signup()),
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
      ),
    ));
  }

  void onLoginClick() {
    setState(() {
      if (_phoneController.text.length != 10 ||
          _phoneController.text.contains(" ") ||
          _passController.text.contains(" ") ||
          _passController.text.length < 5) {
        _signInInvalid = true;
        debugPrint(" co van de");
      } else {
        _signInInvalid = false;
      }
      if (_signInInvalid == false) {
        debugPrint(" k co van de");
      }
      // loginRequest();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const Navigation(
                  selectedIndex: 0,
                )),
      );
    });
  }

  void gotoHomePage() {}
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
          child: SpinKitWave(
        color: Colors.white,
        size: 140,
      )),
    );
  }
}
