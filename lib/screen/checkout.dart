import 'dart:convert';
import 'dart:developer';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:food_app/models/cart_model.dart';
import 'package:food_app/screen/home.dart';
import 'package:food_app/screen/nav_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:momo_vn/momo_vn.dart';
import 'package:flutter/services.dart';
import 'package:zalo_flutter/zalo_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late MomoVn _momoPay;
  late PaymentResponse _momoPaymentResult;
  // ignore: non_constant_identifier_names
  late String _paymentStatus;
  @override
  void initState() {
    super.initState();
    _momoPay = MomoVn();
    _momoPay.on(MomoVn.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _momoPay.on(MomoVn.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _paymentStatus = "";
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('THANH TOÁN QUA ỨNG DỤNG MOMO'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Column(
              children: [
                TextButton(
                  // color: Colors.blue,
                  // textColor: Colors.white,
                  // disabledColor: Colors.grey,
                  // disabledTextColor: Colors.black,
                  // padding: EdgeInsets.all(8.0),
                  // splashColor: Colors.blueAccent,
                  child: Text('DEMO PAYMENT WITH MOMO.VN'),
                  onPressed: () async {
                    MomoPaymentInfo options = MomoPaymentInfo(
                        merchantName: "TTN",
                        appScheme: "MOxx",
                        merchantCode: 'MOxx',
                        partnerCode: 'Mxx',
                        amount: 60000,
                        orderId: '12321312',
                        orderLabel: 'Gói combo',
                        merchantNameLabel: "HLGD",
                        fee: 10,
                        description: 'Thanh toán combo',
                        username: '01234567890',
                        partner: 'merchant',
                        extra: "{\"key1\":\"value1\",\"key2\":\"value2\"}",
                        isTestMode: true);
                    try {
                      _momoPay.open(options);
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                ),
              ],
            ),
            Text(_paymentStatus.isEmpty ? "CHƯA THANH TOÁN" : _paymentStatus)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _momoPay.clear();
  }

  void _setState() {
    _paymentStatus = 'Đã chuyển thanh toán';
    if (_momoPaymentResult.isSuccess == true) {
      _paymentStatus += "\nTình trạng: Thành công.";
      _paymentStatus +=
          "\nSố điện thoại: " + _momoPaymentResult.phoneNumber.toString();
      _paymentStatus += "\nExtra: " + _momoPaymentResult.extra!;
      _paymentStatus += "\nToken: " + _momoPaymentResult.token.toString();
    } else {
      _paymentStatus += "\nTình trạng: Thất bại.";
      _paymentStatus += "\nExtra: " + _momoPaymentResult.extra.toString();
      _paymentStatus += "\nMã lỗi: " + _momoPaymentResult.status.toString();
    }
  }

  void _handlePaymentSuccess(PaymentResponse response) {
    setState(() {
      _momoPaymentResult = response;
      _setState();
    });
    // Fluttertoast.showToast(
    //     msg: "THÀNH CÔNG: " + response.phoneNumber.toString(),
    //     toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentResponse response) {
    setState(() {
      _momoPaymentResult = response;
      _setState();
    });
    // Fluttertoast.showToast(
    //     msg: "THẤT BẠI: " + response.message.toString(),
    //     toastLength: Toast.LENGTH_SHORT);
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text(
  //         "PayPal Checkout",
  //         style: TextStyle(fontSize: 20),
  //       ),
  //     ),
  //     body: Center(
  //       child: TextButton(
  //         onPressed: () async {
  //           Navigator.of(context).push(MaterialPageRoute(
  //             builder: (BuildContext context) => PaypalCheckout(
  //               sandboxMode: true,
  //               clientId:
  //                   "ASoa2JIh2a0Ji0o-tgbJHjPjP3vAEjBhtGQr5llpMvDogQKwA-xrIYd3hqKNQalk2Sk4zV_hmLyirLra",
  //               secretKey:
  //                   "EM5jdjQDv0dIAfRaKCrtAK2uCiIuzUhQVwFmr9CaFwMaN5g_YKvcsgxXP_pJwTtldyJfcma1MU5uc5gZ",
  //               returnURL: "success.snippetcoder.com",
  //               cancelURL: "cancel.snippetcoder.com",
  //               transactions: const [
  //                 {
  //                   "amount": {
  //                     "total": '70',
  //                     "currency": "USD",
  //                     "details": {
  //                       "subtotal": '70',
  //                       "shipping": '0',
  //                       "shipping_discount": 0
  //                     }
  //                   },
  //                   "description": "The payment transaction description.",
  //                   // "payment_options": {
  //                   //   "allowed_payment_method":
  //                   //       "INSTANT_FUNDING_SOURCE"
  //                   // },
  //                   "item_list": {
  //                     "items": [
  //                       {
  //                         "name": "Apple",
  //                         "quantity": 4,
  //                         "price": '5',
  //                         "currency": "USD"
  //                       },
  //                       {
  //                         "name": "Pineapple",
  //                         "quantity": 5,
  //                         "price": '10',
  //                         "currency": "USD"
  //                       }
  //                     ],

  //                     // shipping address is not required though
  //                     //   "shipping_address": {
  //                     //     "recipient_name": "Raman Singh",
  //                     //     "line1": "Delhi",
  //                     //     "line2": "",
  //                     //     "city": "Delhi",
  //                     //     "country_code": "IN",
  //                     //     "postal_code": "11001",
  //                     //     "phone": "+00000000",
  //                     //     "state": "Texas"
  //                     //  },
  //                   }
  //                 }
  //               ],
  //               note: "Contact us for any questions on your order.",
  //               onSuccess: (Map params) async {

  //                 print("onSuccess: $params");
  //               },
  //               onError: (error) {
  //                 print("onError: $error");
  //                 Navigator.pop(context);
  //               },
  //               onCancel: () {
  //                 print('cancelled:');
  //               },
  //             ),
  //           ));
  //         },
  //         style: TextButton.styleFrom(
  //           backgroundColor: Colors.teal,
  //           foregroundColor: Colors.white,
  //           shape: const BeveledRectangleBorder(
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(1),
  //             ),
  //           ),
  //         ),
  //         child: const Text('Checkout'),
  //       ),
  //     ),
  //   );

  // }
}
