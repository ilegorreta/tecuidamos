import 'package:flutter/foundation.dart';
import 'package:tecuidamos/models/task.dart';
import 'dart:collection';
import 'package:tecuidamos/models/user_data.dart';

class Data extends ChangeNotifier {

  UserData _userData = UserData();

  void addUserDataEmailPassword (String newEmail, String newPassword) async {

    final user = UserData(email: newEmail, password: newPassword);
    _userData = user;

    saveUserEmailAndPassword(newEmail, newPassword);
    print('El email de usuario añadido es: ${getUserEmail()}');
    print('El password de usuario añadido es: ${getUserPassword()}');

    notifyListeners();
  }

  String getUserEmail () {
    return _userData.email;
  }

  String getUserPassword () {
    return _userData.password;
  }

  saveUserEmailAndPassword(String email, String password) async {
    final userData = UserData(email: email, password: password);
    _userData = userData;
  }


  List<Task> _tasks = [
    Task(name: '1. Conservar la calma'),
    Task(name: '2. Ubicar ruta de evacuación'),
    Task(name: '3. Evacuar'),
    Task(name: '4 Confirmar situación personal'),
    Task(name: '5. Esperar indicaciones de personal'),
  ];

  int get taskCount => _tasks.length;
  //Lista de solo lectura y no escritura
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  void updateTask(Task task){
    task.toggleDone();
    notifyListeners();
  }

}
