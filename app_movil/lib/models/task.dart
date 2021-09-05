class Task{
  Task({this.name, this.isDone = false});

  final String name;
  bool isDone;

  void toggleDone() {
    //Se invierte el valor que contiene previamente
    isDone = !isDone;
  }

}