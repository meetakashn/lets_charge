import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/utils/routes.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen>
    with SingleTickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    _navigator();
  }

  _navigator() async {
    await Future.delayed(Duration(milliseconds: 2000), () {});
    Navigator.pushReplacementNamed(
      context,
      user != null ? MyRoutes.homeroute : MyRoutes.loginroute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/evl.png',
                width: 190.sp,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Let\'s ",
                    style: TextStyle(
                        fontFamily: GoogleFonts.lato().fontFamily,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Charge",
                    style: TextStyle(
                        fontFamily: GoogleFonts.lato().fontFamily,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green),
                  ),
                ],
              ),
              Text(
                "Go Green Go Electric",
                style: TextStyle(
                    fontFamily: GoogleFonts.lato().fontFamily, fontSize: 18.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
