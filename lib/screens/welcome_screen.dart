import 'package:flash_chat/customWidgets/rounded_button.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String route = '/welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String exp = 'dbksjbd';
  AnimationController controller;
  Animation animation1;
  Animation animation2;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 1,
      ),
    );

    controller.forward();

    animation1 = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    animation2 = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(controller);

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation2.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: animation1.value * 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  speed: Duration(
                    milliseconds: 300,
                  ),
                  displayFullTextOnTap: true,
                  isRepeatingAnimation: false,
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              actionOnPressed: () {
                Navigator.pushNamed(context, LoginScreen.route);
              },
              text: 'Login',
            ),
            RoundedButton(
              color: Colors.blueAccent,
              actionOnPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.route);
              },
              text: 'Register',
            ),
          ],
        ),
      ),
    );
  }
}
