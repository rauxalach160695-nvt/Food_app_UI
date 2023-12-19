import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  DateFormat dateFormat = DateFormat.yMd().add_jm();
  String string = "";
  @override
  void initState() {
    super.initState();
    string = dateFormat.format(DateTime.now());
    debugPrint(string);
    debugPrint("thin");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Đơn mua")),
          backgroundColor: Colors.orange,
          automaticallyImplyLeading: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
          ),
          child: GridView.count(
            childAspectRatio: (8 / 4),
            primary: false,
            padding: const EdgeInsets.all(15),
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
            crossAxisCount: 1,
            children: <Widget>[
              for (var i = 0; i < 10; i++)
                Container(
                  decoration: BoxDecoration(
                      // color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      // border: Border.all(color: Colors.white),
                      color: Color.fromARGB(255, 255, 255, 255)),
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
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
                                        spreadRadius: 1.0)
                                  ],
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://i.pinimg.com/564x/50/3f/13/503f13f2ef189e852844508200a328df.jpg"),
                                      fit: BoxFit.fitWidth)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    string,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "70,000đ",
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  RichText(
                                      text: TextSpan(children: [
                                    WidgetSpan(
                                        child: Icon(
                                      Icons.radio_button_checked,
                                      color: Colors.green,
                                    )),
                                    TextSpan(
                                        text: "Đã giao",
                                        style: TextStyle(
                                          color: Colors.green,
                                        )),
                                  ]))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Center(
                              child: Container(
                                height: 40,
                                width: 130,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.orange),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              side: BorderSide(
                                                  color: Colors.orange)))),
                                  onPressed: () {},
                                  child: Center(
                                      child: Text(
                                    "xem chi tiết",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  )),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                height: 40,
                                width: 130,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.orange),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              side: BorderSide(
                                                  color: Colors.white)))),
                                  onPressed: () {},
                                  child: Center(
                                      child: Text(
                                    "Xóa đơn",
                                    style: TextStyle(
                                        color: Colors.orange, fontSize: 15),
                                  )),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ));
  }
}
