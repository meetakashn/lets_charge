import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/utils/routes.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar:  AppBar(
          toolbarHeight: 50,
          backgroundColor: Colors.green,
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
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            "Booking History",
            style: TextStyle(
                fontFamily: GoogleFonts.aBeeZee().fontFamily,
                fontSize: 18.sp,
                color: Colors.white),
          ),
        ),
        body: Center(
          child: Stack(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        child: Text("No booking found"),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: () {Navigator.pushReplacementNamed(context,MyRoutes.homeroute);},
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //for back button
  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
    return true;
  }
}

