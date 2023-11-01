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
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/pages/accountpage.dart';
import 'package:lets_charge/utils/routes.dart';

import '../indiamap/mapforhome.dart';

class HomePage extends StatefulWidget {
  static var username;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

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
    getdata();
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: Colors.white,
          excludeHeaderSemantics: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                MyRoutes.accountnavroute,
                (route) => false,
              );
            },
            icon: Icon(Icons.account_circle_outlined,
                color: Colors.black54, size: 25.sp),
          ),
          title: Row(
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
                    color: Colors.green,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.lato().fontFamily),
              ),
              SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/images/evl.png",
                width: 42,
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Logout'),
                            onPressed: () async {
                              ProfileEdit.colorenabled = false;
                              await FirebaseAuth.instance.signOut();
                              await GoogleSignIn().signOut();
                              Navigator.pushNamedAndRemoveUntil(context,
                                  MyRoutes.loginroute, (route) => false);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.black54,
                  size: 25.sp,
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: ' Welcome', // First word
                        style: TextStyle(
                          color: Colors.black, // Color of the first word
                          fontSize: 20.sp, // Font size of the first word
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.lato().fontFamily,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' \' ${HomePage.username} \' ', // Second word
                            style: TextStyle(
                              color: Colors.red, // Color of the second word
                              fontSize: 18.sp, // Font size of the second word
                              fontFamily: GoogleFonts.albertSans().fontFamily,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
               SizedBox(height: 10,),
                Center(
                    child: Column(
                      children: [
                        Container(
                            width: 340.w,
                            height: 300.h,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.black),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                MapForHome(),
                                Positioned(
                                  bottom: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SizedBox(
                                      width: 330,
                                      height: 40,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                              context, MyRoutes.initialmapindia);
                                        },
                                        child: Text(
                                          "Explore more stations",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily:
                                            GoogleFonts.lato().fontFamily,
                                            color: Colors.white70,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.h),
                                                side: BorderSide(width: 1)),
                                            backgroundColor: Colors.black,
                                            elevation: 0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Text(" Shortcuts",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.lato().fontFamily)),
                  ],
                ),
                SizedBox(
                  height: 15.sp,
                ),
                Container(
                  height: 90.sp,
                  color: Colors.white12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, MyRoutes.bookinghistory);
                            },
                            child: Container(
                              width: 55, // Adjust the size as needed
                              height: 55, // Adjust the size as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors
                                    .grey.shade200, // Customize the button color
                                //border: Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.history_outlined,
                                  size: 32.sp,
                                  color: Colors.green,
                                  // Customize the icon color
                                ),
                              ),
                            ),
                          ),
                          Text("Booking\nHistory",style: TextStyle(color:Colors.black),textAlign: TextAlign.center,),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context,MyRoutes.walletpage);
                            },
                            child: Container(
                              width: 55, // Adjust the size as needed
                              height: 55, // Adjust the size as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors
                                    .grey.shade200, // Customize the button color
                                //border: Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  size: 32.sp,
                                  color: Colors.green,
                                  // Customize the icon color
                                ),
                              ),
                            ),
                          ),
                          Text("Wallet\n",style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, MyRoutes.favouritestation);
                            },
                            child: Container(
                              width: 55, // Adjust the size as needed
                              height: 55, // Adjust the size as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors
                                    .grey.shade200, // Customize the button color
                                //border: Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 32.sp,
                                  color: Colors.green,
                                  // Customize the icon color
                                ),
                              ),
                            ),
                          ),
                          Text("Favourite\nStations",style: TextStyle(color: Colors.black),textAlign: TextAlign.center),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, MyRoutes.scanpage);
                            },
                            child: Container(
                              width: 55, // Adjust the size as needed
                              height: 55, // Adjust the size as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors
                                    .grey.shade200, // Customize the button color
                               // border: Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.qr_code,
                                  size: 32.sp,
                                  color: Colors.green,
                                  // Customize the icon color
                                ),
                              ),
                            ),
                          ),
                          Text("Scan\n",style: TextStyle(color:Colors.black),textAlign: TextAlign.center,),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  getdata() async {
    User? user = auth.currentUser;
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('profile')
        .doc(user?.uid)
        .get();
    HomePage.username = userDoc.get('name');
  } //getdata

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
                  SystemNavigator.pop();
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
