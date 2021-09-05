import 'package:flutter/material.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:tecuidamos/components/reusable_card.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:tecuidamos/screens/status_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
int contTotalAlumnos;
int contTotalNadie;
int contTotalAfectados;
int contTotalYo;
int contTotalOtro;

class UsersSituationScreen extends StatefulWidget {
  UsersSituationScreen({this.locationWeather});
  final locationWeather;
  static String id = 'users_situation_screen';
  @override
  _UsersSituationScreenState createState() => _UsersSituationScreenState();
}

class _UsersSituationScreenState extends State<UsersSituationScreen> {
  final _auth = FirebaseAuth.instance;
  dynamic prefs;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDecoration(
        title: 'Situación de Alumnos',
        onPressedIcon: () async {
          _auth.signOut();
          //Se elimina el usuario guardado
          prefs = await SharedPreferences.getInstance();
          SPDeleteSaveRead(prefs: prefs).delete();
          Provider.of<Data>(context, listen: false)
              .addUserDataEmailPassword(null, null);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WelcomeScreen(
                        locationWeather: widget.locationWeather,
                      )));
        },
      ),
      body: StatusStream(
        locationWeather: widget.locationWeather,
      ),
    );
  }
}

class StatusStream extends StatelessWidget {
  //TODO: Corregir esto con manejo de estados
  StatusStream({@required this.locationWeather});
  final locationWeather;

  Color colorIcon;
  Icon bubbleIcon;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('Estado')
          //Esto sirve para ordenar los mensajes de manera cronologica
          .orderBy('timeStamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> situationWidgets = [];
        if (!snapshot.hasData) {
          return Center(
            //En esta vez no es necesario decirle cuando deberia empezar a girar y cuando parar. Tan pronto comom cargue destruye la Widget y crea otra con los datos actualizados.
            child: CircularProgressIndicator(
              backgroundColor: kColorBlue,
            ),
          );
        }
        final status = snapshot.data.docs;

        //Reseteo de contador para cada que se utilice esta función
        contTotalAlumnos = 0;
        contTotalNadie = 0;
        contTotalAfectados = 0;
        contTotalYo = 0;
        contTotalOtro = 0;

        for (var situation in status) {
          final situationUser = situation.data()['Usuario'];
          final situationUserAffected = situation.data()['Afectado'];
          final situationUserReport = situation.data()['Situación'];

          contTotalAlumnos++;
          switch (situationUserAffected) {
            case '-':
              contTotalNadie++;
              break;
            case 'Yo':
              contTotalAfectados++;
              contTotalYo++;
              break;
            case 'Alguien Más':
              contTotalAfectados++;
              contTotalOtro++;
              break;
          }

          // print('Contador Total: $contTotalAlumnos');
          // print('Contador -: $contTotalNadie');
          // print('Contador Afectados: $contTotalAfectados');
          // print('Contador Yo: $contTotalYo');
          // print('Contador Alguien Más: $contTotalOtro');

          //Proceso para revisar color del icono
          if (situationUserReport == 'Necesito Ayuda') {
            colorIcon = kColorRed;
          } else {
            colorIcon = kColorGreen;
          }

          //Proceso para determinar el icono
          if (situationUserAffected == 'Alguien Más') {
            bubbleIcon = Icon(
              Icons.people,
              size: 50,
              color: Colors.white,
            );
          } else {
            bubbleIcon = Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            );
          }

          final situationReport = SituationReport(
            user: situationUser,
            affectedUser: situationUserAffected,
            //Como espera un valor booleano, en automatico checa si concuerdan. Si si, asigna true; si no, false.
            colorIcon: colorIcon,
            bubbleIcon: bubbleIcon,
            locationWeather: locationWeather,
            // currentUser == situationSender
          );
          situationWidgets.add(situationReport);
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                //Esta propiedad hace que la vista de los mensajes se desplace al mas reciente
                reverse: false,
                padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                children: situationWidgets,
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    AutoSizeText(
                      'Total de Usuarios: $contTotalAlumnos',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'HNRegular',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      minFontSize: 5,
                      maxFontSize: 15,
                      stepGranularity: 1,
                      maxLines: 1,
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        AutoSizeText(
                          'Usuarios a Salvo: $contTotalNadie',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'HNRegular',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: kColorGreen,
                          ),
                          minFontSize: 5,
                          maxFontSize: 15,
                          stepGranularity: 1,
                          maxLines: 1,
                        ),
                        // SizedBox(
                        //   width: 5,
                        // ),
                        AutoSizeText(
                          'Usuarios en Riesgo: $contTotalAfectados',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'HNRegular',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: kColorRed,
                          ),
                          minFontSize: 5,
                          maxFontSize: 15,
                          stepGranularity: 1,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        AutoSizeText(
                          'Ayuda Mismo Usuario: $contTotalYo',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'HNRegular',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: kColorYellow,
                          ),
                          minFontSize: 5,
                          maxFontSize: 15,
                          stepGranularity: 1,
                          maxLines: 1,
                        ),
                        // SizedBox(
                        //   width: 5,
                        // ),
                        AutoSizeText(
                          'Ayuda Alguien Más: $contTotalOtro',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'HNRegular',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: kColorYellow,
                          ),
                          minFontSize: 5,
                          maxFontSize: 15,
                          stepGranularity: 1,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SituationReport extends StatelessWidget {
  //Funcion para darle formato bonito a los mensajes
  SituationReport(
      {this.user,
      this.affectedUser,
      @required this.colorIcon,
      @required this.bubbleIcon,
      @required this.locationWeather});

  final String user;
  final String affectedUser;
  final Color colorIcon;
  final Icon bubbleIcon;
  final locationWeather;

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      colour: kDarkSecondaryBackground,
      onPress: () {
        print('Presionaste la tarjeta del usuario: $user');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StatusScreen(
                      user: user,
                      locationWeather: locationWeather,
                    )));
      },
      cardChild: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: colorIcon,
              child: bubbleIcon,
              radius: 35,
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AutoSizeText(
                    'Usuario:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'MPLight',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    minFontSize: 5,
                    maxFontSize: 15,
                    stepGranularity: 1,
                    maxLines: 1,
                  ),
                  SizedBox(width: 2.5),
                  AutoSizeText(
                    '$user',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: 'SFLightItalic',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: kColorGreyHint),
                    minFontSize: 5,
                    maxFontSize: 12,
                    stepGranularity: 1,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(
                height: 3,
              ),
              AutoSizeText(
                'Afectado: $affectedUser',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'MPLight',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                minFontSize: 5,
                maxFontSize: 15,
                stepGranularity: 1,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
