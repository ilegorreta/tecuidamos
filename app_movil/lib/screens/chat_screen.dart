import 'package:flutter/material.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:tecuidamos/services/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:tecuidamos/utilities/information_constants.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
TimeOfDay time;
DateTime date;
int contMensajes;
String lastSender;
String currentSender;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  dynamic prefs;
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;
  String hora;
  String minutos;
  String year;
  String month;
  String day;

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
        title: 'TECuidamos | Chat',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MessageStream(),
          Container(
            decoration: kMessageContainerDecoration,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      //Se crea el controlador de texto
                      controller: messageTextController,
                      cursorColor: kColorBlue,
                      //Funciones para display y wrapping de texto (forma de ListView)
                      maxLines: 5,
                      minLines: 1,
                      onChanged: (value) {
                        //Proceso para que no acepte valores nulos
                        messageText = value.trim();
                        if (messageText == '') {
                          messageText = null;
                        }
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (messageText != null) {
                        //Se manda a llamar la funcion que hace que borre el texto en cuanto se manda el mensaje
                        messageTextController.clear();
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

                        Map<String, dynamic> reporteMensaje = {
                          'Texto': messageText,
                          'Usuario': loggedInUser.email,
                          'Año': year,
                          'Mes': month,
                          'Día': day,
                          'Hora': hora,
                          'Minutos': minutos,
                          'Mensaje Visible': true,
                          'timeStamp': FieldValue.serverTimestamp(),
                        };
                        _firestore
                            .collection('Mensajes')
                            .doc('Mensaje $contMensajes')
                            .set(reporteMensaje);
                        messageText = null;
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: kColorPurple,
                      child: Icon(
                        Icons.send,
                        size: 25,
                        color: Colors.white,
                      ),
                      radius: 20,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  Color colorMessage;
  String sender;
  String messageText;
  String messageSender;
  String messageHora;
  String messageMinutos;
  String messageYear;
  String messageMonth;
  String messageDay;
  bool senderVisible;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('Mensajes')
          //Esto sirve para ordenar los mensajes de manera cronologica
          .orderBy('timeStamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> messageWidgets = [];
        if (!snapshot.hasData) {
          return Center(
            //En esta vez no es necesario decirle cuando deberia empezar a girar y cuando parar. Tan pronto comom cargue destruye la Widget y crea otra con los datos actualizados.
            child: CircularProgressIndicator(
              backgroundColor: kColorBlue,
            ),
          );
        }
        final messages = snapshot.data.docs;
        contMensajes = 0;
        for (var message in messages) {
          contMensajes++;
          if (contMensajes > 1) {
            lastSender = currentSender;
            print('El sender anterior fue: $lastSender');
          }
          print('Se tienen $contMensajes mensajes contados');
          messageText = message.data()['Texto'];
          messageSender = message.data()['Usuario'];
          messageHora = message.data()['Hora'];
          messageMinutos = message.data()['Minutos'];
          messageYear = message.data()['Año'];
          messageMonth = message.data()['Mes'];
          messageDay = message.data()['Día'];
          senderVisible = message.data()['Mensaje Visible'];

          currentSender = messageSender;

          //Proceso para revisar color del mensaje
          if (kAdminUser.contains(messageSender)) {
            colorMessage = kColorGreen;
            sender = 'Personal Planta Física';
          } else if (loggedInUser.email == messageSender) {
            colorMessage = kColorPurple;
            sender = messageSender;
          } else {
            colorMessage = kColorBlue;
            sender = messageSender;
          }

          final messageBubble = MessageBubble(
            sender: sender,
            text: messageText,
            //Como esperaun valor booleano, en automatico checa si concuerdan. Si si, asigna true; si no, false.
            isMe: loggedInUser.email == messageSender,
            colorMessage: colorMessage,
            hora: messageHora,
            minutos: messageMinutos,
            year: messageYear,
            month: messageMonth,
            day: messageDay,
            senderVisible: senderVisible,
          );
          messageWidgets.add(messageBubble);
        }

        if (contMensajes > 1) {
          if (lastSender == currentSender) {
            Map<String, dynamic> reporteMensajeAnterior = {
              'Mensaje Visible': false,
            };
            _firestore
                .collection('Mensajes')
                .doc('Mensaje ${contMensajes - 2}')
                .update(reporteMensajeAnterior);
          }
        }

        return Expanded(
          child: ListView(
            //Esta propiedad hace que la vista de los mensajes se desplace al mas reciente
            // reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  //Funcion para darle formato bonito a los mensajes
  MessageBubble({
    this.sender,
    this.text,
    this.isMe,
    @required this.colorMessage,
    @required this.hora,
    @required this.minutos,
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.senderVisible,
  });

  final String sender;
  final String text;
  final bool isMe;
  final Color colorMessage;
  final String hora;
  final String minutos;
  final String year;
  final String month;
  final String day;
  final bool senderVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            //Esta funcion ayuda a darle un radio a cada una de las esquinas
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 30 : 0),
                bottomLeft: Radius.circular(30),
                topRight: Radius.circular(isMe ? 0 : 30),
                bottomRight: Radius.circular(30)),
            //Sombra
            elevation: 5,
            color: colorMessage,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    '$text',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'HNRegular',
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 3),
                  Text(
                    '$day-$month-$year | $hora:$minutos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'SFLight',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: senderVisible,
            child: Column(
              children: [
                SizedBox(height: 3),
                Text(
                  'de $sender',
                  style: TextStyle(
                    fontSize: 12,
                    color: kColorGreyHint,
                    fontFamily: 'SFLightItalic',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
