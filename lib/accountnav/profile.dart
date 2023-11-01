import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/pages/loginpage.dart';

import '../pages/accountpage.dart';
import '../utils/routes.dart';

class ProfileEdit extends StatefulWidget {
  static bool statemang = false, isEnabled = false, colorenabled = false;

  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formField = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  TextEditingController emailidcontroller = TextEditingController();
  String name = "";
  final String wholenum = '${LoginPage.country}${LoginPage.phone}';
  bool isLoading = false;

  @override
  void initState() {
    print(ProfileEdit.colorenabled);
    // TODO: implement initState
    numbercontroller.text = wholenum;
    if (ProfileEdit.statemang) {
      namecontroller.text = AccountNav.username;
      emailidcontroller.text = AccountNav.emailid;
      numbercontroller.text = AccountNav.usernumber;
      name = AccountNav.username;
    } else {
      namecontroller.clear();
      emailidcontroller.clear();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ProfileEdit.isEnabled
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            "assets/images/evlout.png",
                            width: 200,
                            color: Colors.red,
                          ),
                          Image.asset(
                            "assets/images/evlin.png",
                            width: 200,
                            color: ProfileEdit.colorenabled
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                                color: ProfileEdit.colorenabled
                                    ? Colors.green
                                    : Colors.red,
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
                                color: ProfileEdit.colorenabled
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.lato().fontFamily),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                          maxLength: 15,
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
                          enabled: false,
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
                                    ProfileEdit.statemang ? "update" : "submit",
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

  storeUserinfo(){
    RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');
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
        ProfileEdit.statemang = false;
        ProfileEdit.colorenabled = true;
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
    Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
    return true;
  } // _onWillpop
}
