import 'package:flutter/material.dart';

class SPDeleteSaveRead {
  SPDeleteSaveRead({@required this.prefs, this.key, this.email, this.password});
  final prefs;
  String email;
  String password;
  String key;
  String value;

  delete() async {
    key = 'emailKey';
    prefs.remove(key);

    key = 'passwordKey';
    prefs.remove(key);
    print('Values deleted!');
  }
  
  String read() {
    switch(key) {
      case 'emailKey':
        value = prefs.getString(key) ?? 'No Disponible';
        break;
      case 'passwordKey':
        value = prefs.getString(key) ?? 'No Disponible';
        break;
      default:
        value = 'No Recuperado';
    }
    return value;
  }

  save() async {
    //Guardar email
    key = 'emailKey';
    prefs.setString(key, email);

    //Guardar password
    key = 'passwordKey';
    prefs.setString(key, password);
  }
}