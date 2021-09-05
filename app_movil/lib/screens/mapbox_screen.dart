import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/services/weather.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User loggedInUser;
final _firestore = FirebaseFirestore.instance;
var points = <LatLng>[];
List<double> latitudePoint = List<double>(10);
List<double> longitudePoint = List<double>(10);
List<String> instruccionesRuta = List<String>(10);
bool visibleRoute;

class MapboxScreen extends StatefulWidget {
  MapboxScreen({this.latitudeData, this.longitudeData});

  final double latitudeData;
  final double longitudeData;

  static String id = 'mapbox_screen';
  @override
  _MapboxScreenState createState() => _MapboxScreenState();
}

class _MapboxScreenState extends State<MapboxScreen> {
  final _auth = FirebaseAuth.instance;
  dynamic prefs;

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
          title: 'LocalízaTEC',
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
        ),
        body: MapboxRouteStream(
            latitudDescargada: widget.latitudeData,
            longitudDescargada: widget.longitudeData));
  }
}

class MapboxRouteStream extends StatelessWidget {
  MapboxRouteStream(
      {@required this.latitudDescargada, @required this.longitudDescargada});
  final double latitudDescargada;
  final double longitudDescargada;

  int contador;
  int contadorRuta;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('Ruta de Salida')
          .doc('${loggedInUser.email}')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            //En esta vez no es necesario decirle cuando deberia empezar a girar y cuando parar. Tan pronto como cargue destruye la Widget y crea otra con los datos actualizados.
            child: CircularProgressIndicator(
              backgroundColor: kColorBlue,
            ),
          );
        }
        var mapRoute = snapshot.data;
        visibleRoute = mapRoute.data()['Ruta Visible'];

        try {
          contadorRuta = 0;
          for (contador = 0; contador < 5; contador++) {
            if (double.parse(mapRoute.data()['Latitud $contador']) != 0 ||
                double.parse(mapRoute.data()['Longitud $contador']) != 0) {
              latitudePoint[contador] =
                  double.parse(mapRoute.data()['Latitud $contador']);
              longitudePoint[contador] =
                  double.parse(mapRoute.data()['Longitud $contador']);
              instruccionesRuta[contador] =
                  mapRoute.data()['Instrucción $contador'];
              contadorRuta++;
            } else if (double.parse(mapRoute.data()['Latitud $contador']) ==
                        0 &&
                    contadorRuta == 0 ||
                double.parse(mapRoute.data()['Longitud $contador']) == 0 &&
                    contadorRuta == 0) {
              visibleRoute = false;
            } else {
              latitudePoint[contador] = latitudePoint[contadorRuta - 1];
              longitudePoint[contador] = longitudePoint[contadorRuta - 1];
              instruccionesRuta[contador] = instruccionesRuta[contadorRuta - 1];
            }
            print('La latitud obtenida es: ${latitudePoint[contador]}');
            print('La longitud obtenida es: ${longitudePoint[contador]}');
            print('La instrucción obtenida es: ${instruccionesRuta[contador]}');
          }

          if (visibleRoute) {
            points = <LatLng>[
              LatLng(latitudePoint[0], longitudePoint[0]),
              LatLng(latitudePoint[1], longitudePoint[1]),
              LatLng(latitudePoint[2], longitudePoint[2]),
              LatLng(latitudePoint[3], longitudePoint[3]),
              LatLng(latitudePoint[4], longitudePoint[4]),
              //LatLng(latitudePoint[5], longitudePoint[5]),
              //LatLng(latitudePoint[6], longitudePoint[6]),
              //LatLng(latitudePoint[7], longitudePoint[7]),
              //LatLng(latitudePoint[8], longitudePoint[8]),
              //LatLng(latitudePoint[9], longitudePoint[9]),
            ];
          } else {
            points = [];
          }
        } catch (e) {
          print(e);
          points = [];
        }

        return FlutterMap(
          options: MapOptions(
            center: LatLng(latitudDescargada, longitudDescargada),
            minZoom: 2,
            maxZoom: 18.25,
            zoom: 16,
            enableMultiFingerGestureRace: true,
            // slideOnBoundaries: true,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/evacuacion/ckkt78ub11vrx17mugjhzl2f8/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXZhY3VhY2lvbiIsImEiOiJjazFlZXduN2cwYXJyM2xsYnZtNzJxYzZvIn0._5d2oSdZNEfPdf2AY2cvVQ',
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoiZXZhY3VhY2lvbiIsImEiOiJjazFlZXo4enAwMWNlM25ucnA1c2FkOGZmIn0.UPN-A0LvF8IKcL3EjAkRoA',
                'id': 'mapbox.mapbox-streets-v8',
              },
            ),
            MarkerLayerOptions(markers: [
              Marker(
                width: 45,
                height: 45,
                point: LatLng(latitudDescargada, longitudDescargada),
                builder: (context) => Container(
                  child: IconButton(
                    icon: Icon(Icons.person_pin_circle_sharp),
                    color: kColorRed,
                    iconSize: 45,
                    onPressed: () {
                      print('Marker typed');
                    },
                  ),
                ),
              ),
            ]),

            // Así se trazaría la ruta de evacuación. Basta con descomentar este código.
            PolylineLayerOptions(
              polylines: [
                Polyline(
                  points: points,
                  strokeWidth: 5,
                  color: kColorBlue,
                )
              ],
            ),
          ],
          nonRotatedChildren: <Widget>[
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoundedButton(
                        paddingRight: 7.5,
                        paddingBottom: 20,
                        color: kColorPurple,
                        title: 'Generar Ruta',
                        onPressed: () {
                          print('Generar Ruta fue presionado');
                          Map<String, dynamic> reporte = {
                            'Ruta Visible': true,
                          };
                          _firestore
                              .collection('Ruta de Salida')
                              .doc('${loggedInUser.email}')
                              .update(reporte);
                        },
                        fontFamily: 'HNBold',
                      ),
                      RoundedButton(
                        paddingLeft: 7.5,
                        paddingBottom: 20,
                        color: kColorRed,
                        title: 'Borrar Ruta',
                        onPressed: () {
                          print('Borrar Ruta fue presionado');
                          Map<String, dynamic> reporte = {
                            'Ruta Visible': false,
                          };
                          _firestore
                              .collection('Ruta de Salida')
                              .doc('${loggedInUser.email}')
                              .update(reporte);
                        },
                        fontFamily: 'HNBold',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
