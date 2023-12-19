import 'package:flutter/material.dart';

class View_rating extends StatefulWidget {
  const View_rating({super.key});

  @override
  State<View_rating> createState() => _View_ratingState();
}

class _View_ratingState extends State<View_rating> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(left: 15, top: 10),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(100)),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: Color.fromARGB(255, 255, 255, 255))))),
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
    );
  }
}
