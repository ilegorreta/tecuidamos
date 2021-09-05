import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/screens/admin_screen.dart';
import 'package:tecuidamos/screens/main_loading_screen.dart';
import 'package:tecuidamos/screens/mapbox_screen.dart';
import 'package:tecuidamos/screens/places_situation_screen.dart';
import 'package:tecuidamos/screens/users_situation_screen.dart';
import 'package:tecuidamos/screens/welcome_screen.dart';
import 'package:tecuidamos/screens/registration_screen.dart';
import 'package:tecuidamos/screens/login_screen.dart';
import 'package:tecuidamos/screens/main_screen.dart';
import 'package:tecuidamos/screens/chat_screen.dart';
import 'package:tecuidamos/screens/status_screen.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:tecuidamos/models/data.dart';

void main() async {
  //Inicializacion del programa y configuracion a solo Portraitup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new TECuidamos());
  });
}

class TECuidamos extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Data(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          backgroundColor: kDarkMainBackground,
          scaffoldBackgroundColor: kDarkMainBackground,
          textSelectionColor: kColorPurple,
        ),
        //Seleccion de pagina de inicio
        initialRoute: MainLoadingScreen.id,
        //Creacion de rutas
        routes: {
          ChatScreen.id: (context) => ChatScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          MainLoadingScreen.id: (context) => MainLoadingScreen(),
          MainScreen.id: (context) => MainScreen(),
          MapboxScreen.id: (context) => MapboxScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          AdminScreen.id: (context) => AdminScreen(),
          UsersSituationScreen.id: (context) => UsersSituationScreen(),
          PlacesSituationScreen.id: (context) => PlacesSituationScreen(),
          StatusScreen.id: (context) => StatusScreen(),
        },
      ),
    );
  }
}
