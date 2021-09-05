import 'package:flutter/material.dart';
import 'package:tecuidamos/widgets/task_tile.dart';
import 'package:provider/provider.dart';
import 'package:tecuidamos/models/data.dart';

//Como ya no se le asigna un valor por medio de clases padre (herencias), y se pasa directamente, ya no necesita ser una clase Stateful
class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Data>(
      builder: (context, taskData, child){
        return ListView.builder(itemBuilder: (context, index){
          final taskShortcut = taskData.tasks[index];
          return TaskTile(
            taskTitle: taskShortcut.name,
            isChecked: taskShortcut.isDone,
            checkboxCallback: (checkboxState){
              taskData.updateTask(taskShortcut);
            },
            // longPressCallback: (){
            //   taskData.deleteTask(taskShortcut);
            // },
          );
        },
          itemCount: taskData.taskCount,
        );
      },
    );
  }
}