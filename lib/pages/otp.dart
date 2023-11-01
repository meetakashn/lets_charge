import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/pages/loginpage.dart';
import 'package:pinput/pinput.dart';

import '../utils/routes.dart';

class Otp extends StatefulWidget {
  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var code = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 22.sp),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset(
                  "assets/images/otpbg.png",
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                    "Enter your\n"
                    "Verification Code",
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: GoogleFonts.lato().fontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1),
                    textAlign: TextAlign.center),
                SizedBox(
                  height: 5.h,
                ),
                Text("Sended to ${LoginPage.country + LoginPage.phone}",
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: GoogleFonts.lato().fontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                SizedBox(
                  height: 13.h,
                ),
                SizedBox(
                  width: 300.w,
                  child: Pinput(
                    length: 6,
                    showCursor: true,
                    onChanged: (value) {
                      code = value;
                    },
                    defaultPinTheme: PinTheme(
                      width: 56.w,
                      height: 53.h,
                      textStyle: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                    width: 304.w,
                    height: 32.h,
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              try {
                                PhoneAuthCredential credential =
                                    PhoneAuthProvider.credential(
                                        verificationId: LoginPage.verify,
                                        smsCode: code);
                                await auth.signInWithCredential(credential);
                                setState(() {
                                  isLoading = true;
                                });
                                decideroute();
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Error"),
                                      content: Text("Please enter right"
                                          " verification code"),
                                      actions: [
                                        TextButton(
                                          child: Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(
                              "Verify phone number",
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.h)),
                                backgroundColor: Colors.lightGreen,
                                elevation: 2))),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, MyRoutes.loginroute, (route) => false);
                        },
                        child: const Text("Edit your number ?",
                            style: TextStyle(color: Colors.black)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(left: 32.sp),
                            alignment: Alignment.topLeft)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  decideroute() {
    //check user login?
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      //check profile exists
      FirebaseFirestore.instance
          .collection('profile')
          .doc(user.uid)
          .get()
          .then((value) {
        if (value.exists) {
          isLoading = false;
          Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
        } else {
          ProfileEdit.isEnabled = false;
          ProfileEdit.statemang = false;
          isLoading = false;
          Navigator.pushReplacementNamed(context, MyRoutes.profileeditroute);
        }
      });
    }
  } //decideroute

//for back button
  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, MyRoutes.loginroute);
    return true;
  } // _onWillpop
}
