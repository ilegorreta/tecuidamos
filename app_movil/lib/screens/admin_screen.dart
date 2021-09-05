import 'package:flutter/material.dart';
import 'package:tecuidamos/components/appbar_decoration.dart';
import 'package:tecuidamos/components/reusable_card.dart';
import 'package:tecuidamos/screens/users_situation_screen.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:tecuidamos/screens/chat_screen.dart';
import 'package:tecuidamos/screens/places_situation_screen.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tecuidamos/components/rounded_button.dart';
import 'package:tecuidamos/models/data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecuidamos/services/sp_delete_save_read.dart';

User loggedInUser;

class AdminScreen extends StatefulWidget {
  AdminScreen({this.locationWeather});
  final locationWeather;
  static String id = 'admin_screen';
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
        title: 'TECuidamos | Admin',
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
        returnIcon: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ReusableCard(
              colour: kDarkSecondaryBackground,
              cardChild: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 7.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: CircleAvatar(
                        backgroundColor: kColorPurple,
                        child: Flexible(
                          child: Icon(
                            Icons.people,
                            size: 75,
                            color: Colors.white,
                          ),
                        ),
                        radius: 200,
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
              cardChild: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 7.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: CircleAvatar(
                        backgroundColor: kColorPurple,
                        child: Icon(
                          Icons.warning,
                          size: 75,
                          color: Colors.white,
                        ),
                        radius: 200,
                      ),
                    ),
                    RoundedButton(
                      color: kColorRed,
                      title: 'Situación de Alumnos',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UsersSituationScreen(
                                      locationWeather: widget.locationWeather,
                                    )));
                      },
                      fontFamily: 'HNBold',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              child: ReusableCard(
                colour: kDarkSecondaryBackground,
                cardChild: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 7.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CircleAvatar(
                          backgroundColor: kColorPurple,
                          child: Icon(
                            Icons.workspaces_filled,
                            size: 75,
                            color: Colors.white,
                          ),
                          radius: 200,
                        ),
                      ),
                      RoundedButton(
                        color: kColorGreen,
                        title: 'Conteo por Salón',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlacesSituationScreen(
                                        locationWeather: widget.locationWeather,
                                      )));
                        },
                        fontFamily: 'HNBold',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
