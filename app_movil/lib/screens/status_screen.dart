import 'package:flutter/material.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/components/reusable_card.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

User loggedInUser;
TimeOfDay time;
String hora;
String minutos;
DateTime date;
String year;
String month;
String day;
final _firestore = FirebaseFirestore.instance;

class StatusScreen extends StatefulWidget {
  StatusScreen({this.user, this.locationWeather});
  final String user;
  final locationWeather;
  static String id = 'status_screen';
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final _auth = FirebaseAuth.instance;
  dynamic prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarDecoration(
          title: 'Reporte de Status',
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
        body: IndividualStatusStream(
            locationWeather: widget.locationWeather, user: widget.user));
  }
}

class IndividualStatusStream extends StatelessWidget {
  IndividualStatusStream({@required this.locationWeather, @required this.user});
  final locationWeather;
  final user;

  Color colorIcon;
  Icon bubbleIcon;
  bool visibleButton;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('Estado').doc('$user').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            //En esta vez no es necesario decirle cuando deberia empezar a girar y cuando parar. Tan pronto como cargue destruye la Widget y crea otra con los datos actualizados.
            child: CircularProgressIndicator(
              backgroundColor: kColorBlue,
            ),
          );
        }
        var situation = snapshot.data;

        final situationUserAffected = situation.data()['Afectado'];
        final situationUserReport = situation.data()['Situación'];
        final situationUserBuilding = situation.data()['Edificio'];
        final situationUserRoom = situation.data()['Salón'];
        final situationUserLatitude = situation.data()['Latitud'];
        final situationUserLongitude = situation.data()['Longitud'];
        final situationDescription = situation.data()['Descripción'];
        final situationHora = situation.data()['Hora'];
        final situationMinutos = situation.data()['Minutos'];
        final situationYear = situation.data()['Año'];
        final situationMonth = situation.data()['Mes'];
        final situationDay = situation.data()['Día'];

        //Proceso para revisar color del icono
        if (situationUserReport == 'Necesito Ayuda') {
          colorIcon = kColorRed;
          visibleButton = true;
        } else {
          colorIcon = kColorGreen;
          visibleButton = false;
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

        return Column(
          children: [
            ReusableCard(
              colour: kDarkSecondaryBackground,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'Reportado el $situationDay-$situationMonth-$situationYear a las $situationHora:$situationMinutos',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'MPLight',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        minFontSize: 5,
                        maxFontSize: 13,
                        stepGranularity: 1,
                        maxLines: 1,
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          AutoSizeText(
                            'Usuario:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'MPLight',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            minFontSize: 5,
                            maxFontSize: 13,
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
                                fontSize: 10,
                                color: kColorGreyHint),
                            minFontSize: 5,
                            maxFontSize: 10,
                            stepGranularity: 1,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      AutoSizeText(
                        'Afectado: $situationUserAffected',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'MPLight',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        minFontSize: 5,
                        maxFontSize: 13,
                        stepGranularity: 1,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReusableCard(
                colour: kDarkSecondaryBackground,
                cardChild: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AutoSizeText(
                        'Edificio: $situationUserBuilding',
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
                      SizedBox(height: 5),
                      AutoSizeText(
                        'Salón: $situationUserRoom',
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
                      SizedBox(height: 5),
                      AutoSizeText(
                        'Latitud: $situationUserLatitude',
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
                      SizedBox(height: 5),
                      AutoSizeText(
                        'Longitud: $situationUserLongitude',
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
                      SizedBox(height: 5),
                      AutoSizeText(
                        'Descripción: $situationDescription',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'HNRegular',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        minFontSize: 5,
                        maxFontSize: 15,
                        stepGranularity: 1,
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Visibility(
                visible: visibleButton,
                child: RoundedButton(
                  title: 'Alumno Atendido',
                  onPressed: () {
                    //Se crean los datos del reporte y se actualiza la base de datos
                    print('El alumno atendido fue: $user');

                    time = TimeOfDay.now();
                    date = DateTime.now();
                    if (time.hour >= 0 && time.hour <= 9) {
                      hora = '0${time.hour}';
                    } else {
                      hora = '${time.hour}';
                    }
                    if (time.minute >= 0 && time.minute <= 9) {
                      minutos = '0${time.minute}';
                    } else {
                      minutos = '${time.minute}';
                    }
                    year = '${date.year}';
                    if (date.month >= 0 && date.month <= 9) {
                      month = '0${date.month}';
                    } else {
                      month = '${date.month}';
                    }
                    if (date.day >= 0 && date.day <= 9) {
                      day = '0${date.day}';
                    } else {
                      day = '${date.day}';
                    }

                    Map<String, dynamic> reporte = {
                      'Situación': 'Fuera de Riesgo',
                      'Afectado': '-',
                      'Descripción': '-',
                      'Edificio': '-',
                      'Salón': '-',
                      'Latitud': '-',
                      'Longitud': '-',
                      'Año': year,
                      'Mes': month,
                      'Día': day,
                      'Hora': hora,
                      'Minutos': minutos,
                      'Usuario': user,
                      'timeStamp': FieldValue.serverTimestamp(),
                    };
                    _firestore.collection('Estado').doc(user).set(reporte);
                  },
                  paddingTop: 0,
                  color: kColorPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
