import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lets_charge/accountnav/bookinghist.dart';
import 'package:lets_charge/accountnav/profile.dart';
import 'package:lets_charge/googlelogin/googleprofile.dart';
import 'package:lets_charge/pages/accountpage.dart';
import 'package:lets_charge/pages/favouritestation.dart';
import 'package:lets_charge/pages/homepage.dart';
import 'package:lets_charge/pages/notificationpage.dart';
import 'package:lets_charge/pages/otp.dart';
import 'package:lets_charge/pages/scanpage.dart';
import 'package:lets_charge/pages/wallet.dart';
import 'package:lets_charge/splashscreen.dart';
import 'package:lets_charge/utils/routes.dart';

import 'indiamap/initialmapindia.dart';
import 'indiamap/mapforhome.dart';
import 'pages/loginpage.dart';
import 'widgets/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    androidProvider: AndroidProvider.debug,
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  runApp(const app());
}

class app extends StatefulWidget {
  const app({super.key});

  @override
  State<app> createState() => _appState();
}

class _appState extends State<app> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    getConnectivity();
    super.initState();
  }

  //internet checker
  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox(context);
            setState(() => isAlertSet = true);
          }
        },
      );

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) {
          return MaterialApp(
            themeMode: ThemeMode.light,
            theme: Mytheme.lighttheme(context),
            darkTheme: Mytheme.darktheme(context),
            debugShowCheckedModeBanner: false,
            initialRoute: MyRoutes.scanpage,
            routes: {
              MyRoutes.loginroute: (context) => LoginPage(),
              MyRoutes.homeroute: (context) => HomePage(),
              MyRoutes.otproute: (context) => Otp(),
              MyRoutes.accountnavroute: (context) => AccountNav(),
              MyRoutes.splashscreenroute: (context) => splashscreen(),
              MyRoutes.profileeditroute: (context) => ProfileEdit(),
              MyRoutes.googleprofileeditroute: (context) => GoogleProfileEdit(),
              MyRoutes.initialmapindia: (context) => InitialMapIndia(),
              MyRoutes.mapforhome: (context) => MapForHome(),
              MyRoutes.favouritestation: (context) => FavouriteStation(),
              MyRoutes.bookinghistory: (context) => BookingHistory(),
              MyRoutes.notificationpage: (context) => NotificationPage(),
              MyRoutes.scanpage: (context) => ScanPage(),
              MyRoutes.walletpage: (context) => WalletPage(),
            },
          );
        });
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
}
