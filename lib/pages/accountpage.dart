import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/utils/routes.dart';

class AccountNav extends StatefulWidget {
  static String username = "";
  static String emailid = "";
  static String usernumber = "";

  const AccountNav({super.key});

  @override
  State<AccountNav> createState() => _AccountNavState();
}

class _AccountNavState extends State<AccountNav> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, MyRoutes.homeroute, (route) => false);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 25.sp,
              ),
            ),
          ),
          title: Text(
            "Account",
            style: TextStyle(
                fontFamily: GoogleFonts.aBeeZee().fontFamily,
                fontSize: 18.sp,
                color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: TextButton(
                  onPressed: () {
                    ProfileEdit.colorenabled = true;
                    getdata();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: Colors.black54,
                        size: 28.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Profile",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: GoogleFonts.lato().fontFamily)),
                          SizedBox(
                            height: 6.h,
                          ),
                          Text(
                            "update name, phone number or email",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 4.h,
                thickness: 2.sp,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.bookinghistory, (route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_outlined,
                        color: Colors.black54,
                        size: 28.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Booking history",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: GoogleFonts.lato().fontFamily)),
                          SizedBox(
                            height: 6.h,
                          ),
                          Text(
                            "View history of all the bookings\ndone and the details of the\nbookings",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 4.h,
                thickness: 2.sp,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.notificationpage, (route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        color: Colors.black54,
                        size: 28.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Notifications",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: GoogleFonts.lato().fontFamily)),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            "Get updates and alerts and about EV\ncharging, and more",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 4.h,
                thickness: 2.sp,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, MyRoutes.homeroute, (route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.black54,
                        size: 28.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Help",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: GoogleFonts.lato().fontFamily)),
                          SizedBox(
                            height: 6.h,
                          ),
                          Text(
                            "Explore our app to get information",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 4.h,
                thickness: 2.sp,
              ),
              SizedBox(
                height: 240.h,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 25.h),
                child: TextButton(
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
                    child: Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontFamily: GoogleFonts.lato().fontFamily,
                          letterSpacing: 1),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(width: 1, color: Colors.green)),
                      backgroundColor: Colors.white10,
                      fixedSize: Size(double.maxFinite, 50.h),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  getdata() async {
    User? user = auth.currentUser;
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('profile')
        .doc(user?.uid)
        .get();
    AccountNav.username = userDoc.get('name');
    AccountNav.emailid = userDoc.get('emailid');
    AccountNav.usernumber = userDoc.get('phonenumber');
    ProfileEdit.statemang = true;
    ProfileEdit.isEnabled = true;
    Navigator.pushNamedAndRemoveUntil(
        context, MyRoutes.profileeditroute, (route) => false);
  } //getdata

  //for back button
  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
    return true;
  } // _onWillpop
}
