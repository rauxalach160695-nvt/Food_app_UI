import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:food_app/screen/home.dart';
import 'package:food_app/screen/cart.dart';
import 'package:food_app/screen/order.dart';
import 'package:food_app/screen/profile.dart';
import 'package:food_app/screen/chat.dart';

class Navigation extends StatefulWidget {
  final int selectedIndex;
  const Navigation({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int _selectedIndex;
  void initState() {
    _selectedIndex = widget.selectedIndex;
  }

  void _navigationBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    Home(),
    Cart(),
    Order(),
    Profile(),
    Chat_screen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          // color: Colors.blue,
          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          // ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: GNav(
                selectedIndex: _selectedIndex,
                color: Color.fromARGB(255, 197, 195, 195),
                activeColor: Colors.orange,
                tabBackgroundColor: Color.fromARGB(255, 224, 224, 224),
                padding: EdgeInsets.all(8),
                gap: 8,
                onTabChange: _navigationBottomBar,
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: 'Trang chủ',
                  ),
                  GButton(
                    icon: Icons.shopping_cart,
                    text: 'Giỏ hàng',
                  ),
                  GButton(
                    icon: Icons.assignment,
                    text: 'Đơn mua',
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Tài khoản',
                  ),
                  GButton(
                    icon: Icons.question_answer,
                    text: 'Hỗ trợ',
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
