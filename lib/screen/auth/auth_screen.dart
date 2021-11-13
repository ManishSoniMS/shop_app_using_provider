import 'dart:math';
import 'package:flutter/material.dart';
import 'widget/auth_card.dart';



class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  static const String routeName = "/auth";

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const AuthScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 225, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceHeight,
              width: deviceWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RotatedContainer(height: deviceHeight, width: deviceWidth),
                  Flexible(
                    flex: deviceWidth > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RotatedContainer extends StatelessWidget {
  const RotatedContainer({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -8 * pi / 180,
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.04),
        padding: EdgeInsets.symmetric(
            vertical: height * 0.005, horizontal: width * 0.1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.deepOrange.shade900,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black26,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          "MyShop",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 50,
            fontFamily: "Anton",
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

