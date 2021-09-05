import 'package:flutter/material.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:tecuidamos/screens/registration_screen.dart';
import 'package:tecuidamos/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({this.locationWeather});
  final locationWeather;
  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'TECuidamos',
              child: Image.asset(
                'images/TECuidamos.png',
                height: 100,
                width: 100,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            //En lugar de poner la funcion Text, se utilizaria esta (o algun otro efecto)
            TypewriterAnimatedTextKit(
              text: ['TECuidamos'],
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 35.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'MPLight',
              ),
              isRepeatingAnimation: true,
            ),
            SizedBox(
              height: 30.0,
            ),
            RoundedButton(
              color: kColorPurple,
              title: 'Iniciar Sesión',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(
                              locationWeather: widget.locationWeather,
                            )));
              },
              fontFamily: 'HNRegular',
            ),
            RoundedButton(
              color: kColorBlue,
              title: 'Registrarse',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen(
                              locationWeather: widget.locationWeather,
                            )));
              },
              fontFamily: 'HNRegular',
            ),
          ],
        ),
      ),
    );
  }
}
