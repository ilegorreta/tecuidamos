import 'package:flutter/material.dart';
import 'package:tecuidamos/screens/main_screen.dart';
import 'package:tecuidamos/screens/admin_screen.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/widgets/alert_display.dart';
import 'package:tecuidamos/utilities/information_constants.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({this.locationWeather});
  final locationWeather;
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  dynamic prefs;

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: kColorBlue,
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'TECuidamos',
                  child: Container(
                    height: 150.0,
                    child: Image.asset('images/TECuidamos.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              Flexible(
                child: TextField(
                  cursorColor: kColorBlue,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value.trim();
                    email = email.toLowerCase();
                    print(email);
                    if (email == '') {
                      email = null;
                    }
                  },
                  //Ejemplo de como se utilizaria la constante pero cambiando un valor de la misma
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Ingresa tu correo electrónico'),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Flexible(
                child: TextField(
                  cursorColor: kColorBlue,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value.trim();
                    if (password == '') {
                      password = null;
                    }
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Ingresa tu contraseña'),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: kColorPurple,
                title: 'Iniciar',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (user != null) {
                      prefs = await SharedPreferences.getInstance();
                      SPDeleteSaveRead(
                              prefs: prefs, email: email, password: password)
                          .save();
                      Provider.of<Data>(context, listen: false)
                          .addUserDataEmailPassword(email, password);
                      if (kAdminUser.contains(email)) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminScreen(
                                      locationWeather: widget.locationWeather,
                                    )));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen(
                                      locationWeather: widget.locationWeather,
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
                    await AlertDisplay(
                      context: context,
                      mainIcon: 'Error',
                      title: 'Error',
                      description: 'Verifica tu usuario y tu contraseña.',
                      button1: 'Regresar',
                      onPressed1: () {
                        Navigator.pop(context);
                      },
                    ).alert();
                  }
                },
                fontFamily: 'HNRegular',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
