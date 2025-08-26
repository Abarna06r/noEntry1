import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  final String message;
  const AlertScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.2 > 100 ? 100.0 : size.width * 0.2;
    final fontSize = size.width * 0.07 > 28 ? 28.0 : size.width * 0.07;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.white, size: iconSize),
              SizedBox(height: size.height * 0.03),
              Text(
                message,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.06),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.02),
                ),
                child: Text("Dismiss Alert", style: TextStyle(color: Colors.white, fontSize: size.width * 0.045 > 18 ? 18 : size.width * 0.045)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
