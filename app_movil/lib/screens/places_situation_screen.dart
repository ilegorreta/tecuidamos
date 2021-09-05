import 'package:flutter/material.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:tecuidamos/components/reusable_card.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tecuidamos/utilities/information_constants.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
int contTotalAlumnos;
int contTotalAlumnosDentro;
int contTotalAlumnosFuera;
List<int> contSalon = List<int>(kPlaceIdentified.length);
List<Color> contColorSalon = List<Color>(kPlaceIdentified.length);

class PlacesSituationScreen extends StatefulWidget {
  PlacesSituationScreen({this.locationWeather});
  final locationWeather;
  static String id = 'places_situation_screen';
  @override
  _PlacesSituationScreenState createState() => _PlacesSituationScreenState();
}

class _PlacesSituationScreenState extends State<PlacesSituationScreen> {
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
        title: 'Conteo por Salón',
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
      body: StatusStream(),
    );
  }
}

class StatusStream extends StatelessWidget {
  String situationBuilding;
  String situationRoom;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('Estado')
          //Esto sirve para ordenar los mensajes de manera cronologica
          .orderBy('timeStamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> situationRoomWidgets = [];
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
        contTotalAlumnosDentro = 0;
        contTotalAlumnosFuera = 0;
        //Llenar de 0's el arreglo (lista) y de color rojo los salones
        for (var i = 0; i < kPlaceIdentified.length; i++) {
          contSalon[i] = 0;
          contColorSalon[i] = kColorBlue;
        }

        for (var situation in status) {
          //Esta variable queda comentada porque por el momento no hace nada, ya que solo hay un edificio
          //situationBuilding = situation.data()['Edificio'];
          situationRoom = situation.data()['Salón'];

          contTotalAlumnos++;
          if (situationRoom == '-') {
            contTotalAlumnosFuera++;
          } else {
            contTotalAlumnosDentro++;
          }

          for (var i = 0; i < kPlaceIdentified.length; i++) {
            if (situationRoom.contains(kPlaceIdentified[i])) {
              contSalon[i]++;
              if (contSalon[i] < kStudentsQuantity[i] &&
                  (kStudentsQuantity[i] - contSalon[i]) > 5) {
                contColorSalon[i] = kColorGreen;
              } else if (contSalon[i] < kStudentsQuantity[i]) {
                contColorSalon[i] = kColorYellow;
              } else {
                contColorSalon[i] = kColorRed;
              }
            }
          }
        }

        for (var i = 0; i < kPlaceIdentified.length; i++) {
          final situationRoomReport = SituationRoomReport(
            building: 'CDTC',
            room: kPlaceIdentified[i],
            //Como espera un valor booleano, en automatico checa si concuerdan. Si si, asigna true; si no, false.
            colorIcon: contColorSalon[i],
            total: contSalon[i],
            // currentUser == situationSender
          );
          situationRoomWidgets.add(situationRoomReport);
          Map<String, dynamic> reporte = {
            'Edificio': 'CDTC',
            'Salón': '${kPlaceIdentified[i]}',
            'Total': contSalon[i],
            'timeStamp': FieldValue.serverTimestamp(),
          };
          _firestore
              .collection('Conteo de Alumnos por Salón')
              .doc('CDTC ${kPlaceIdentified[i]}')
              .set(reporte);
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
                children: situationRoomWidgets,
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
                          'Dentro del Campus: $contTotalAlumnosDentro',
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
                          'Fuera del Campus: $contTotalAlumnosFuera',
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

class SituationRoomReport extends StatelessWidget {
  //Funcion para darle formato bonito a los mensajes
  SituationRoomReport(
      {this.building,
      this.room,
      @required this.colorIcon,
      @required this.total});

  final String building;
  final String room;
  final Color colorIcon;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      colour: kDarkSecondaryBackground,
      cardChild: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: colorIcon,
              child: Icon(
                Icons.store,
                size: 50,
                color: Colors.white,
              ),
              radius: 35,
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Edificio: $building',
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
              SizedBox(
                height: 3,
              ),
              AutoSizeText(
                'Salón: $room',
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
              AutoSizeText(
                'Total: $total',
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
