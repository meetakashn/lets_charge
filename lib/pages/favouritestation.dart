import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/utils/routes.dart';

class FavouriteStation extends StatefulWidget {
  const FavouriteStation({super.key});

  @override
  State<FavouriteStation> createState() => _FavouriteStationState();
}

class _FavouriteStationState extends State<FavouriteStation> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
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
            "Favourite Station",
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
                        child: Text("No Favourite Station Found"),
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
