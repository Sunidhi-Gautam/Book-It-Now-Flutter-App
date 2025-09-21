// ignore_for_file: file_names

import '../models/constants.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  @override
  Widget build(BuildContext context) {
    double heightSize= MediaQuery.of(context).size.height;
    double widthSize= MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: heightSize,
          width: widthSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 52,
                width: widthSize-60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: grey)
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email_rounded),
                    hintText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
