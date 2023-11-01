import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../pages/accountpage.dart';
import '../utils/routes.dart';

class GoogleProfileEdit extends StatefulWidget {
  static bool statemang = false, isEnabled = false;

  const GoogleProfileEdit({super.key});

  @override
  State<GoogleProfileEdit> createState() => _GoogleProfileEditState();
}

class _GoogleProfileEditState extends State<GoogleProfileEdit> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  final _formField = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  TextEditingController emailidcontroller = TextEditingController();
  String name = "";
  bool colorenable = false;
  bool isLoading = false;
  bool googleisenable = true;

  @override
  void initState() {
    // TODO: implement initState
    getConnectivity();
    // Set up the subscription to listen for changes
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      handleConnectivityChange(result);
    });
    numbercontroller.text = "+91";
    getthestatemang();
    name = namecontroller.text;

    super.initState();
  }

  getthestatemang() async {
    if (GoogleProfileEdit.statemang) {
      namecontroller.text = AccountNav.username;
      emailidcontroller.text = AccountNav.emailid;
      numbercontroller.text = AccountNav.usernumber;
      name = AccountNav.username;
    } else {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('profile')
            .doc(user.uid)
            .get();
        String? googlename = user.displayName;
        String? googleemail = user.email;
        namecontroller.text = googlename ?? "";
        emailidcontroller.text = googleemail ?? "";
        name = googlename ?? "";
      }
    }
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
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GoogleProfileEdit.isEnabled
                ? IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, MyRoutes.homeroute, (route) => false);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 25.sp,
                      color: Colors.black,
                    ),
                  )
                : null,
          ),
          title: Text(
            "Profile",
            style: TextStyle(
                fontFamily: GoogleFonts.lato().fontFamily,
                fontSize: 18.sp,
                color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Stack(children: [
                        Image.asset(
                          "assets/images/evlout.png",
                          width: 200,
                          color: Colors.red,
                        ),
                        Image.asset(
                          "assets/images/evlin.png",
                          width: 200,
                          color: colorenable ? Colors.green : Colors.red,
                        )
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Let\'s',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                          Text(
                            ' Charge',
                            style: TextStyle(
                                color: colorenable ? Colors.red : Colors.green,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome\'s',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                          Text(
                            ' $name',
                            style: TextStyle(
                                color: colorenable ? Colors.green : Colors.red,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      )
                    ],
                  ),
                ),
                Divider(
                  thickness: 2,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Form(
                    key: _formField,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "   Profile Details",
                          style: TextStyle(
                              fontFamily: GoogleFonts.lato().fontFamily,
                              color: Colors.black,
                              fontSize: 15.sp),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          "   Name",
                          style: TextStyle(
                              fontFamily: GoogleFonts.lato().fontFamily,
                              color: Colors.black54),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        TextFormField(
                          controller: namecontroller,
                          maxLength: 25,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                            prefixIcon: Icon(
                              Icons.account_circle,
                              color: Colors.black,
                            ),
                            hintText: "Name",
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              isLoading = false;
                              return "name cannot be empty";
                            }
                          },
                          onChanged: (value) {
                            name = value;
                            namecontroller.text = value;
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "   Phone Number",
                          style: TextStyle(
                              fontFamily: GoogleFonts.lato().fontFamily,
                              color: Colors.black54),
                        ),
                        TextFormField(
                          controller: numbercontroller,
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.black,
                            ),
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          enabled: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              isLoading = false;
                              return 'number cannot be empty';
                            }
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "   Email Id",
                          style: TextStyle(
                              fontFamily: GoogleFonts.lato().fontFamily,
                              color: Colors.black54),
                        ),
                        TextFormField(
                          controller: emailidcontroller,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            hintText: "Enter Email Id",
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              isLoading = false;
                              return 'email cannot be empty';
                            }
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 35.h,
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (_formField.currentState!.validate()) {
                                      storeUserinfo();
                                    }
                                  },
                                  child: Text(
                                    "update",
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.lato().fontFamily),
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor: Colors.green.shade500)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  storeUserinfo() {
    RegExp indiaPhoneRegex = RegExp(r'^\+91[1-9]\d{9}$');
    RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');
    if (indiaPhoneRegex.hasMatch(numbercontroller.text)) {
      if (nameRegex.hasMatch(namecontroller.text)) {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance.collection('profile').doc(uid).set({
          'name': namecontroller.text,
          'phonenumber': numbercontroller.text,
          'emailid': emailidcontroller.text,
        }).then((value) {
          namecontroller.clear();
          numbercontroller.clear();
          emailidcontroller.clear();
          setState(() {
            isLoading = false;
          });
          colorenable = true;
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showToastName(context);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      _showToast(context);
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

  void _showToastName(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Please enter a valid name'),
      ),
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
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  } // _onWillpop

  //dialog internet
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
}
