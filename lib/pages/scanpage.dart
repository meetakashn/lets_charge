import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/utils/routes.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Future<void> scanQRCode() async {
  }

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
            "scan",
            style: TextStyle(
                fontFamily: GoogleFonts.aBeeZee().fontFamily,
                fontSize: 18.sp,
                color: Colors.white),
          ),
        ),
        body:Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () async {
                scanQRCode();
              },
              child: Icon(Icons.add),
            ),
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

