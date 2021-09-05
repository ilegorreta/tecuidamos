import 'package:flutter/material.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:tecuidamos/screens/mapbox_screen.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:tecuidamos/services/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tecuidamos/components/reusable_card.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:tecuidamos/screens/chat_screen.dart';
import 'package:tecuidamos/widgets/task_list.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tecuidamos/services/location.dart';
import 'package:tecuidamos/widgets/alert_display.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:tecuidamos/services/beacon_identifier.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
TimeOfDay time;
String hora;
String minutos;
DateTime date;
String year;
String month;
String day;

class MainScreen extends StatefulWidget {
  MainScreen({this.locationWeather});
  final locationWeather;
  static String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  dynamic prefs;
  Location location = Location();
  String latitude;
  String longitude;
  WeatherModel weather = WeatherModel();
  int temperature;
  String weatherIcon;
  String weatherMessage;
  String cityName;
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String messageText;
  bool buildingVisible = false;
  //Variables para Beacons
  var isRunning = false;
  var _salon = '-';
  var _beaconBuilding = 'CDTC';
  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    print(widget.locationWeather);
    try {
      updateUI(widget.locationWeather);
    } catch (e) {
      print(e);
      temperature = 0;
      weatherIcon = 'Error';
      weatherMessage = 'Algo salió mal LOL\'nt :(';
      cityName = '';
    }
    getCurrentUser();
    autoInitialize();
  }

  @override
  //Segun yo esto detiene el Beacon cuando se cambia de pantalla
  void dispose() {
    beaconEventsController.close();
    super.dispose();
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

  void autoInitialize() async {
    initPlatformState();
    await BeaconsPlugin.startMonitoring;
    setState(() {
      isRunning = true;
    });
  }

  // Proceso para Beacons
  Future<void> initPlatformState() async {
    var id;

    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Permiso para acceder a su ubicación",
          message: "Esta app necesita su ubicación para trabajar con beacons");

      //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
      //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    await BeaconsPlugin.addRegion(
        "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty) {
            setState(() {
              id = data.trimRight();
            });
            // print("Beacons DataReceived: " + data);
            _salon = BeaconIdentifier(beaconData: id).getPlace();
            if (_salon != '-') {
              buildingVisible = true;
            } else {
              buildingVisible = false;
            }
            addBeaconData(building: _beaconBuilding, room: _salon);
          }
          // else {
          //   setState(() {
          //     _salon = "-";
          //   });
          // }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring;
          setState(() {
            isRunning = true;
          });
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring;
      setState(() {
        isRunning = true;
      });
    }

    if (!mounted) return;
  }

  void updateUI(dynamic weatherData) {
    //Esto se mete dentro de set state para hacer la actualizacion de datos del estado
    setState(() {
      //Reliza lo siguiente si no puede obtener la ubicacion
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = 'Error';
        weatherMessage = 'Algo salió mal LOL\'nt :(';
        cityName = '';
        //Con esta instruccion le dices que salga de la funcion y ya no opera lo demas
        return;
      }

      try {
        double temp = weatherData['main']['temp'];
        temperature = temp.toInt();
      } catch (e) {
        print(e);
        temperature = weatherData['main']['temp'];
      }

      //Variable que solo existe aqui adentro
      var condition = weatherData['weather'][0]['id'];
      weatherIcon = weather.getWeatherIcon(condition);
      weatherMessage = weather.getMessage(temperature);
      cityName = weatherData['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDecoration(
        title: 'TECuidamos',
        onPressedIcon: () async {
          _auth.signOut();
          //Se elimina el usuario guardado
          prefs = await SharedPreferences.getInstance();
          SPDeleteSaveRead(prefs: prefs).delete();
          Provider.of<Data>(context, listen: false)
              .addUserDataEmailPassword(null, null);
          var weatherData = await WeatherModel().getLocationWeather();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WelcomeScreen(
                        locationWeather: weatherData,
                      )));
        },
        returnIcon: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ReusableCard(
                    colour: kDarkSecondaryBackground,
                    cardChild: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: CircleAvatar(
                              backgroundColor: kColorPurple,
                              child: Icon(
                                Icons.people,
                                size: 50,
                                color: Colors.white,
                              ),
                              radius: 40,
                            ),
                          ),
                          RoundedButton(
                            color: kColorBlue,
                            title: 'ComunícaTEC',
                            onPressed: () {
                              Navigator.pushNamed(context, ChatScreen.id);
                            },
                            fontFamily: 'HNBold',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: kDarkSecondaryBackground,
                    cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: AutoSizeText(
                            '$temperatureºC',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'MPLight',
                              fontWeight: FontWeight.w600,
                              fontSize: 40,
                            ),
                            minFontSize: 20,
                            maxFontSize: 40,
                            stepGranularity: 1,
                            maxLines: 1,
                          ),
                        ),
                        Flexible(
                          child: AutoSizeText(
                            cityName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'SFLight',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            minFontSize: 6,
                            maxFontSize: 13,
                            stepGranularity: 1,
                            maxLines: 1,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: AutoSizeText(
                            weatherIcon,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'MPLight',
                              fontWeight: FontWeight.w600,
                              fontSize: 80,
                            ),
                            minFontSize: 40,
                            maxFontSize: 80,
                            stepGranularity: 1,
                            maxLines: 1,
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 7.5, right: 7.5),
                            child: AutoSizeText(
                              weatherMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'HNRegular',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              minFontSize: 7,
                              maxFontSize: 15,
                              stepGranularity: 1,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ReusableCard(
                    colour: kDarkSecondaryBackground,
                    onPress: () async {
                      try {
                        await location.getCurrentLocationHigh();
                      } catch (e) {
                        print(e);
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapboxScreen(
                                    latitudeData: location.latitude,
                                    longitudeData: location.longitude,
                                  )));
                    },
                    cardChild: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Image.asset(
                              'images/Mapbox Preview.png',
                              height: 300,
                              width: 300,
                            ),
                          ),
                          SizedBox(height: 5),
                          AutoSizeText(
                            'LocalízaTEC',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SFLight',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            minFontSize: 6,
                            maxFontSize: 15,
                            stepGranularity: 1,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: kDarkSecondaryBackground,
                    cardChild: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              'Te encuentras en:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'SFLight',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              minFontSize: 6,
                              maxFontSize: 13,
                              stepGranularity: 1,
                              maxLines: 1,
                            ),
                          ),
                          Visibility(
                            visible: buildingVisible,
                            child: Flexible(
                              flex: 2,
                              child: AutoSizeText(
                                '$_beaconBuilding',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'MPLight',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30,
                                ),
                                minFontSize: 12,
                                maxFontSize: 30,
                                stepGranularity: 1,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(
                              '$_salon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'MPLight',
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                              ),
                              minFontSize: 12,
                              maxFontSize: 30,
                              stepGranularity: 1,
                              maxLines: 1,
                            ),
                          ),
                          RoundedButton(
                            flex: 3,
                            color: kColorGreen,
                            title: 'Fuera de Riesgo',
                            onPressed: () async {
                              await AlertDisplay(
                                context: context,
                                mainIcon: 'Info',
                                title: 'Situación: Fuera de Riesgo',
                                description:
                                    'Presiona el botón para confirmar.',
                                button1: 'Confirmar',
                                onPressed1: () async {
                                  Navigator.pop(context);
                                  createData(situation: 'Fuera de Riesgo');
                                  await AlertDisplay(
                                    context: context,
                                    mainIcon: 'Info',
                                    title: 'Situación: Fuera de Riesgo',
                                    description:
                                        '¡Muchas gracias por notificarnos!',
                                    button1: 'Regresar',
                                    onPressed1: () {
                                      Navigator.pop(context);
                                    },
                                  ).alert();
                                },
                              ).alert();
                            },
                            fontFamily: 'HNBold',
                          ),
                          RoundedButton(
                            flex: 3,
                            color: kColorRed,
                            title: 'Necesito Ayuda',
                            onPressed: () async {
                              await AlertDisplay(
                                context: context,
                                mainIcon: 'Warning',
                                title: 'Situación: En busca de ayuda',
                                description: '¿Quién necesita ser atendido?',
                                buttonsQuantity: 2,
                                button1: 'Yo',
                                onPressed1: () async {
                                  Navigator.pop(context);
                                  await AlertDisplay(
                                    context: context,
                                    mainIcon: 'Warning',
                                    title: 'Situación: En busca de ayuda',
                                    description:
                                        'Conserva la calma donde estés. La ayuda viene en camino.',
                                    button1: 'Regresar',
                                    onPressed1: () async {
                                      Navigator.pop(context);
                                      try {
                                        await location.getCurrentLocationHigh();
                                        latitude = '${location.latitude}';
                                        longitude = '${location.longitude}';
                                      } catch (e) {
                                        print(e);
                                        latitude = '-';
                                        longitude = '-';
                                      }
                                      createData(
                                        situation: 'Necesito Ayuda',
                                        affectedUser: 'Yo',
                                        latitude: latitude,
                                        longitude: longitude,
                                        building: _beaconBuilding,
                                        room: _salon,
                                      );
                                    },
                                  ).alert();
                                },
                                button2: 'Alguien Más',
                                button2Color: kColorBlue,
                                onPressed2: () async {
                                  Navigator.pop(context);
                                  await AlertDisplay(
                                    context: context,
                                    mainIcon: 'Warning',
                                    title: 'Situación: En busca de ayuda',
                                    textFieldChild: TextField(
                                      autofocus: true,
                                      controller: messageTextController,
                                      cursorColor: kColorBlue,
                                      maxLines: 5,
                                      minLines: 1,
                                      maxLength: 500,
                                      onChanged: (value) {
                                        messageText = value.trim();
                                        if (messageText == '') {
                                          messageText = null;
                                        }
                                      },
                                      decoration: kMessageTextFieldDecoration,
                                    ),
                                    button1: 'Reportar',
                                    button1Color: kColorBlue,
                                    onPressed1: () async {
                                      Navigator.pop(context);
                                      messageTextController.clear();
                                      try {
                                        await location.getCurrentLocationHigh();
                                        latitude = '${location.latitude}';
                                        longitude = '${location.longitude}';
                                      } catch (e) {
                                        print(e);
                                        latitude = '-';
                                        longitude = '-';
                                      }
                                      if (messageText != null) {
                                        createData(
                                          situation: 'Necesito Ayuda',
                                          affectedUser: 'Alguien Más',
                                          description: messageText,
                                          latitude: latitude,
                                          longitude: longitude,
                                          building: _beaconBuilding,
                                          room: _salon,
                                        );
                                        messageText = null;
                                      } else {
                                        createData(
                                          situation: 'Necesito Ayuda',
                                          affectedUser: 'Alguien Más',
                                          description: '-',
                                          latitude: latitude,
                                          longitude: longitude,
                                          building: _beaconBuilding,
                                          room: _salon,
                                        );
                                      }
                                      await AlertDisplay(
                                        context: context,
                                        mainIcon: 'Warning',
                                        title: 'Situación: En busca de ayuda',
                                        description:
                                            'Conserven la calma donde estén, la ayuda viene en camino.',
                                        button1: 'Regresar',
                                        button1Color: kColorBlue,
                                        onPressed1: () {
                                          Navigator.pop(context);
                                        },
                                      ).alert();
                                    },
                                  ).alertTextField();
                                },
                              ).alert();
                            },
                            fontFamily: 'HNBold',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              child: ReusableCard(
                colour: kDarkSecondaryBackground,
                cardChild: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 7.5),
                  child: TasksList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

createData(
    {@required String situation,
    String affectedUser = '-',
    String description = '-',
    String latitude = '-',
    String longitude = '-',
    String building = '-',
    String room = '-'}) {
  DocumentReference documentReference =
      _firestore.collection('Estado').doc(loggedInUser.email);

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
    'Situación': situation,
    'Afectado': affectedUser,
    'Descripción': description,
    'Edificio': building,
    'Salón': room,
    'Latitud': latitude,
    'Longitud': longitude,
    'Usuario': loggedInUser.email,
    'Año': year,
    'Mes': month,
    'Día': day,
    'Hora': hora,
    'Minutos': minutos,
    'timeStamp': FieldValue.serverTimestamp(),
  };

  documentReference.set(reporte);
}

addBeaconData({String building = '-', String room = '-'}) {
  DocumentReference documentReference =
      _firestore.collection('Estado').doc(loggedInUser.email);

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
    'Usuario': loggedInUser.email,
    'Edificio': building,
    'Salón': room,
    'Año': year,
    'Mes': month,
    'Día': day,
    'Hora': hora,
    'Minutos': minutos,
    'timeStamp': FieldValue.serverTimestamp(),
  };
  documentReference.update(reporte);

  documentReference =
      _firestore.collection('Ruta de Entrada').doc(loggedInUser.email);
  Map<String, dynamic> reporte2 = {
    'Usuario': loggedInUser.email,
    'Edificio': building,
    'Salón': room,
    'timeStamp': FieldValue.serverTimestamp(),
  };
  documentReference.set(reporte2);
}
