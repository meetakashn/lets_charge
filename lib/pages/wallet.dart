import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_charge/utils/routes.dart';

class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
          "wallet",
          style: TextStyle(
              fontFamily: GoogleFonts.aBeeZee().fontFamily,
              fontSize: 18.sp,
              color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Available Balance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "\$100.00", // Replace with the actual balance amount
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
               Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
              },
              child: Text("Add Funds"),
            ),
            SizedBox(height: 20),
            Text(
              "Transaction History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // You can create a list of transaction history items here
                  WalletTransactionItem(
                    description: "Payment for service A",
                    amount: "-\$50.00",
                  ),
                  WalletTransactionItem(
                    description: "Payment for service B",
                    amount: "-\$30.00",
                  ),
                  WalletTransactionItem(
                    description: "Deposit",
                    amount: "+\$100.00",
                  ),
                  // Add more transaction items as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletTransactionItem extends StatelessWidget {
  final String description;
  final String amount;

  WalletTransactionItem({required this.description, required this.amount});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(description),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: amount.startsWith('-') ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
