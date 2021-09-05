import 'package:flutter/material.dart';
import 'package:tecuidamos/screens/main_screen.dart';
import 'package:tecuidamos/screens/admin_screen.dart';
import 'package:tecuidamos/utilities/information_constants.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/widgets/alert_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({this.locationWeather});
  final locationWeather;
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  dynamic prefs;
  String password1;
  bool finalPassword = false;

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
              //Esta Widget para adaptar a un formato flexible a los elementos que contiene
              //Por ejemplo, aqui lo que dice es que por default ponga una height de 200, pero en caso de que no quepa y pueda causar errores lo adaptara
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
                  //Facilita el teclado del usuario
                  cursorColor: kColorBlue,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value.trim();
                    email = email.toLowerCase();
                    if (email == '') {
                      email = null;
                    }
                  },
                  //Ejemplo de como se utilizaria la constante pero cambiando un valor de la misma
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Ingresa tu correo electrónico',
                  ),
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
                    if (password == password1) {
                      finalPassword = true;
                    } else {
                      finalPassword = false;
                    }
                  },
                  //Ejemplo de como se utilizaria la constante pero cambiando un valor de la misma
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Ingresa tu contraseña'),
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
                    password1 = value.trim();
                    if (password1 == '') {
                      password1 = null;
                    }
                    if (password == password1) {
                      finalPassword = true;
                    } else {
                      finalPassword = false;
                    }
                  },
                  //Ejemplo de como se utilizaria la constante pero cambiando un valor de la misma
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Reingresa tu contraseña'),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: kColorBlue,
                title: 'Registrar',
                onPressed: () async {
                  setState(() {
                    //En este momento (tras apretar el boton) se activa el spinner
                    //No para de girar hasta que se le indica cuando
                    showSpinner = true;
                  });
                  if (finalPassword == true) {
                    finalPassword = false;
                    try {
                      //De esta forma se registra al usuario, pero es necesario asignar valor futuro, dado que no sabemos cuanto tarde este proceso
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      //Se revisa que no este vacio el campo para registrar
                      if (newUser != null) {
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
                          Map<String, dynamic> reporte = {
                            'Situación': 'Fuera de Riesgo',
                            'Afectado': '-',
                            'Descripción': '-',
                            'Edificio': '-',
                            'Salón': '-',
                            'Latitud': '-',
                            'Longitud': '-',
                            'Usuario': email,
                            'Año': '-',
                            'Mes': '-',
                            'Día': '-',
                            'Hora': '-',
                            'Minutos': '-',
                            'timeStamp': FieldValue.serverTimestamp(),
                          };
                          _firestore
                              .collection('Estado')
                              .doc(email)
                              .set(reporte);

                          Map<String, dynamic> reporte2 = {
                            'Instrucciones 0': '-',
                            'Instrucciones 1': '-',
                            'Instrucciones 2': '-',
                            'Instrucciones 3': '-',
                            'Instrucciones 4': '-',
                            'Instrucciones 5': '-',
                            'Instrucciones 6': '-',
                            'Instrucciones 7': '-',
                            'Instrucciones 8': '-',
                            'Instrucciones 9': '-',
                            'Latitud 0': 0,
                            'Latitud 1': 0,
                            'Latitud 2': 0,
                            'Latitud 3': 0,
                            'Latitud 4': 0,
                            'Latitud 5': 0,
                            'Latitud 6': 0,
                            'Latitud 7': 0,
                            'Latitud 8': 0,
                            'Latitud 9': 0,
                            'Longitud 0': 0,
                            'Longitud 1': 0,
                            'Longitud 2': 0,
                            'Longitud 3': 0,
                            'Longitud 4': 0,
                            'Longitud 5': 0,
                            'Longitud 6': 0,
                            'Longitud 7': 0,
                            'Longitud 8': 0,
                            'Longitud 9': 0,
                            'Ruta Visible': true,
                          };
                          _firestore
                              .collection('Ruta de Salida')
                              .doc(email)
                              .set(reporte2);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                        locationWeather: widget.locationWeather,
                                      )));
                        }
                      }
                      setState(() {
                        //En este momento (tras apretar el boton) se desactiva el spinner
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
                        description: 'No fue posible registrar el usuario.',
                        button1: 'Regresar',
                        onPressed1: () {
                          Navigator.pop(context);
                        },
                      ).alert();
                    }
                  } else {
                    setState(() {
                      showSpinner = false;
                    });
                    await AlertDisplay(
                      context: context,
                      mainIcon: 'Error',
                      title: 'Error',
                      description: 'Las contraseñas no coinciden',
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
