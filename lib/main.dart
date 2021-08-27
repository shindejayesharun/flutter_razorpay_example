import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_razorpay_example/razorpay_order_response.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const platform = const MethodChannel("razorpay_flutter");

  late Razorpay _razorpay;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout(RazorpayOrderResponse data) async {
    //key - rzp_test_q0FLy0FYnKC94V
    //secret - 2QSokzIEPn80sW6iIICczD7v
    var options = {
      'key': 'rzp_test_q0FLy0FYnKC94V',
      'amount': 2000,
      'order_id':'${data.id}',
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  Future<dynamic> createOrder() async {
    var mapHeader = new Map<String, String>();
    mapHeader['Authorization'] = "Basic cnpwX3Rlc3RfcTBGTHkwRlluS0M5NFY6MlFTb2t6SUVQbjgwc1c2aUlJQ2N6RDd2";
    mapHeader['Accept'] = "application/json";
    mapHeader['Content-Type'] = "application/x-www-form-urlencoded";
    var map =  new Map<String, String>();
    map['amount'] = "2000";
    map['currency'] = "INR";
    map['receipt']  = "receipt1";
    print("map ${map}");
    var response = await http.post(Uri.https( "api.razorpay.com","/v1/orders"),headers:mapHeader,body: map );
    print("...."+response.body);
    if (response.statusCode == 200) {
      RazorpayOrderResponse data  = RazorpayOrderResponse.fromJson(json.decode(response.body));
      openCheckout(data);
    }
  }


  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Center(child: RaisedButton(onPressed:(){
       createOrder();
     } , child: Text('Open'))),
   );
  }
}
