// ignore_for_file: file_names

import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';  // ⛔ Commented out

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Test Without Razorpay',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Razorpay _razorpay; // ⛔ Commented out

  @override
  void initState() {
    super.initState();

    // ⛔ Razorpay initialization (disabled)
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    // ⛔ Dispose Razorpay (disabled)
    // _razorpay.clear();
  }

  // ⛔ Razorpay functions disabled
  // void _openCheckout() {
  //   var options = {
  //     'key': 'rzp_test_key',
  //     'amount': 50000, // 500 INR in paise
  //     'name': 'Test Payment',
  //     'description': 'UI Testing only',
  //   };
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   }
  // }
  //
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   print("Payment Success: ${response.paymentId}");
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   print("Payment Error: ${response.code} - ${response.message}");
  // }
  //
  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   print("External Wallet: ${response.walletName}");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UI Test - Razorpay Disabled")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "This is the payment screen UI.\nRazorpay is disabled.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // onPressed: _openCheckout, // ⛔ Disabled
              onPressed: () {
                print("Payment button pressed (UI only, no Razorpay).");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Razorpay disabled - UI only")),
                );
              },
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
