import 'package:flutter/material.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:tecuidamos/screens/admin_screen.dart';
import 'package:tecuidamos/services/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/screens/main_screen.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/utilities/information_constants.dart';

class MainLoadingScreen extends StatefulWidget {
  static String id = 'main_loading_screen';
  @override
  _MainLoadingScreenState createState() => _MainLoadingScreenState();
}

class _MainLoadingScreenState extends State<MainLoadingScreen> {
  String email;
  String password;
  String mensaje;
  dynamic prefs;

  var weatherData;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  void precharge() async {
    //Se obtiene mensaje, usuario y contraseña guardado
    mensaje = '';
    prefs = await SharedPreferences.getInstance();
    email = SPDeleteSaveRead(prefs: prefs, key: 'emailKey').read();
    password = SPDeleteSaveRead(prefs: prefs, key: 'passwordKey').read();
    setState(() {});

    //Se obtiene geolocalizacion y clima
    weatherData = await WeatherModel().getLocationWeather();

    //Se autentica el usuario obtenido en la Firebase
    if (email != 'No Disponible' && password != 'No Disponible') {
      mensaje = 'Ingresando como $email';
      setState(() {
        showSpinner = true;
      });
      try {
        final user = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (user != null) {
          Provider.of<Data>(context, listen: false)
              .addUserDataEmailPassword(email, password);
          if (kAdminUser.contains(email)) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminScreen(
                          locationWeather: weatherData,
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(
                          locationWeather: weatherData,
                        )));
          }
        }
        setState(() {
          showSpinner = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          showSpinner = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomeScreen(
                      locationWeather: weatherData,
                    )));
      }
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                    locationWeather: weatherData,
                  )));
    }
  }

  @override
  void initState() {
    super.initState();
    precharge();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: kColorBlue,
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Hero(
                  tag: 'TECuidamos',
                  child: Image.asset(
                    'images/TECuidamos.png',
                    height: 200,
                    width: 200,
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  mensaje,
                  style: TextStyle(
                    color: kColorGreyHint,
                    fontSize: 12,
                    fontFamily: 'SFLightItalic',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
