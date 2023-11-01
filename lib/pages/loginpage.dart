import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/routes.dart';

class LoginPage extends StatefulWidget {
  static String verify = "";
  static String phone = "";
  static String country = "";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController countrycode = TextEditingController();
  final _formField = GlobalKey<FormState>();
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isLoading = false;
  bool isLoadgoogle = false;

  @override
  void initState() {
    // TODO: implement initState
    countrycode.text = "+91";
    LoginPage.country = countrycode.text;
    getConnectivity();
    // Set up the subscription to listen for changes
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      handleConnectivityChange(result);
    });
    super.initState();
  }

  //internet checker
  getConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox(context);
      setState(() => isAlertSet = true);
    }
  }

  void handleConnectivityChange(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      if (!isDeviceConnected && isAlertSet == false) {
        showDialogBox(context);
        setState(() => isAlertSet = true);
      }
    } else {
      // You can handle cases when the device is connected here
      // For example, you can dismiss the dialog if it's open
      if (isAlertSet) {
        Navigator.of(context).pop(); // Dismiss the dialog
        setState(() => isAlertSet = false);
      }
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          body: Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Image.asset("assets/images/loginbg.png",
                    height: 240.h, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text("Let's Charge",
                  style: TextStyle(
                      letterSpacing: 2,
                      fontFamily: GoogleFonts.lato().fontFamily,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(
                height: 18.h,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.h),
                    child: const Text(
                      "Log in or Sign up",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                height: 45.h,
                width: 300.w,
                margin: const EdgeInsets.all(Checkbox.width),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.w, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _formField,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40.w,
                        height: 45.h,
                        child: TextFormField(
                          enabled: false,
                          onChanged: (value) {
                            countrycode.text = value;
                            LoginPage.country = value;
                          },
                          maxLength: 5,
                          textAlign: TextAlign.end,
                          controller: countrycode,
                          style: TextStyle(fontSize: 15.sp),
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter code";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        "|",
                        style: TextStyle(fontSize: 30.sp, color: Colors.grey),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: TextFormField(
                            maxLength: 10,
                            onChanged: (value) {
                              LoginPage.phone = value;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              counterText: "",
                              border: InputBorder.none,
                              hintText: " Mobile Number",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  width: 304.w,
                  height: 35.h,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            RegExp indiaPhoneRegex =
                                RegExp(r'^\+91[1-9]\d{9}$');
                            if (indiaPhoneRegex.hasMatch(
                                '${countrycode.text + LoginPage.phone}')) {
                              setState(() {
                                isLoading = true;
                              });
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                phoneNumber:
                                    '${countrycode.text + LoginPage.phone}',
                                verificationCompleted:
                                    (PhoneAuthCredential credential) async {
                                  credential = credential;
                                  await FirebaseAuth.instance
                                      .signInWithCredential(credential);
                                },
                                verificationFailed:
                                    (FirebaseAuthException e) {},
                                codeSent:
                                    (String verificationId, int? resendToken) {
                                  LoginPage.verify = verificationId;
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pushNamed(
                                      context, MyRoutes.otproute);
                                },
                                codeAutoRetrievalTimeout:
                                    (String verificationId) {},
                              );
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              _showToast(context);
                            }
                          },
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.lato().fontFamily),
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.red))),
              SizedBox(
                height: 13.h,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.h),
                    child: const Text(
                      "or",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 13.h,
              ),
              Center(
                child: isLoadgoogle
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isLoadgoogle = true;
                          });
                          googleLogin();
                        },
                        icon: Image.asset(
                          "assets/images/google.png",
                          width: 40.w,
                          height: 18.h,
                        ),
                        label: Text(
                          "Google",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.lato().fontFamily,
                              fontSize: 20,
                              letterSpacing: 1),
                          textAlign: TextAlign.center,
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.sp, horizontal: 89.sp),
                          backgroundColor: Colors.white,
                          side: const BorderSide(width: 0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        )),
              ),
            ],
          ),
        ),
      )),
    );
  }
  googleLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      if (result == null) {
        return;
      }
      final userData = await result.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: userData.accessToken, idToken: userData.idToken);
      var finalResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      checkforgooglelogin();
    } catch (error) {
      print(error);
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Please enter a valid mobile number'),
      ),
    );
  }

  checkforgooglelogin() {
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
          setState(() {
            isLoadgoogle = false;
          });
          Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
        } else {
          setState(() {
            isLoadgoogle = false;
          });
          Navigator.pushReplacementNamed(
              context, MyRoutes.googleprofileeditroute);
        }
      });
    }
  }

  showDialogBox(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("No Connection"),
      content: Text("Please check your internet connectivity"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () async {
            Navigator.of(context).pop();
            setState(() => isAlertSet = false);
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox(context);
              setState(() => isAlertSet = true);
            }
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //for back button
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  setState(() {
                    isLoadgoogle = false;
                  });
                  SystemNavigator.pop();
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  } // _onWillpop
}
