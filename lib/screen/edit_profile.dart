import 'package:flutter/material.dart';
import 'package:food_app/screen/cart.dart';
import '../models/user_info_model.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_app/screen/loading_page.dart' as ld;
import 'package:food_app/screen/nav_screen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.userInfo});

  final User_Info userInfo;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _userController = new TextEditingController();
  TextEditingController _nowPassController = new TextEditingController();
  TextEditingController _newPassController = new TextEditingController();
  TextEditingController _cfPassController = new TextEditingController();
  var _signInErr = "Mật khẩu mới và mật khẩu xác nhận không trùng khớp!";
  var _nowPasswordVisible;
  var _newPasswordVisible;
  var _cfPasswordVisible;
  late bool _isLoading = false;

  Future<http.Response> changeUserName() async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'userName': _userController.text
    };

    final response = await http.put(
        Uri.parse("${dotenv.env['API_HOST']}/user/editUserName"),
        headers: headers,
        body: jsonEncode(jsonBody));

    if (response.statusCode == 200) {
      setState(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Navigation(selectedIndex: 2)));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    return response;
  }

  Future<http.Response> changeUserPass() async {
    _isLoading = true;
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map jsonBody = {
      'token': await SessionManager().get('accessToken'),
      'currentPass': _nowPassController.text,
      'newPass': _newPassController.text
    };

    final response = await http.put(
        Uri.parse("${dotenv.env['API_HOST']}/user/editPass"),
        headers: headers,
        body: jsonEncode(jsonBody));

    if (response.statusCode == 200) {
      setState(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Navigation(selectedIndex: 2)));
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
    _nowPasswordVisible = false;
    _newPasswordVisible = false;
    _cfPasswordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const ld.LoadingPage()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(left: 15, top: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100)),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
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
                    ),
                    SizedBox(
                      height: 40,
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
                                image: AssetImage('images/avatar.png'),
                                fit: BoxFit.fitWidth),
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      widget.userInfo.userName.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Thông tin tài khoản",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Tên ngừời dùng",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        ChangeUserNameDialog(context);
                      },
                      child: Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange)),
                        child: Text(
                          widget.userInfo.userName.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Số điện thoại",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange)),
                      child: Text(
                        widget.userInfo.phoneNumber.toString(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Mật khẩu",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        ChangePasswordDialog(context);
                      },
                      child: Container(
                          height: 50,
                          padding: EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange)),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.black,
                                size: 10,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void ChangeUserNameDialog(BuildContext context) {
    showGeneralDialog(
        context: context,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation1, animation2) {
          return Container();
        },
        transitionBuilder: (context, a1, a2, widget) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
              child: AlertDialog(
                title: const Text("Đổi tên người dùng"),
                content: Container(
                  height: 80,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey)),
                          hintText: "Không quá 20 kí tự",
                          labelText: "Tên người dùng mới"),
                    ),
                  ),
                ),
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      changeUserName();
                    },
                  ),
                  TextButton(
                    child: const Text('Hủy'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void ChangePasswordDialog(BuildContext context) {
    showGeneralDialog(
        context: context,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation1, animation2) {
          return Container();
        },
        transitionBuilder: (context, a1, a2, widget) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
              child: AlertDialog(
                title: const Text("Đổi mật khẩu"),
                content: Container(
                    height: 210,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.grey)),
                          child: TextField(
                            controller: _nowPassController,
                            obscureText: _nowPasswordVisible,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              hintText: "Mật khẩu hiện tại",
                              labelText: "Mật khẩu hiện tại",
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.grey)),
                          child: TextField(
                            controller: _newPassController,
                            obscureText: _newPasswordVisible,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              hintText: "Không có cách và dài 6-20 kí tự",
                              labelText: "Mật khẩu mới",
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.grey)),
                          child: TextField(
                            controller: _cfPassController,
                            obscureText: _cfPasswordVisible,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              hintText: "Không có cách và dài 6-20 kí tự",
                              labelText: "Xác nhân mật khẩu",
                            ),
                          ),
                        ),
                      ],
                    )),
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      if (_newPassController.text == _cfPassController.text) {
                        changeUserPass();
                      } else {
                        debugPrint("hai mat khau khong giong nhau");
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('Hủy'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
