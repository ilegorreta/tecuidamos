import 'package:flutter/material.dart';
import 'package:tecuidamos/utilities/constants.dart';

class TaskTile extends StatelessWidget {
  TaskTile({this.isChecked, this.taskTitle, this.checkboxCallback, this.longPressCallback});
  final bool isChecked;
  final String taskTitle;
  final Function checkboxCallback;
  final Function longPressCallback;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: longPressCallback,
      title: Text(
        taskTitle,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          fontFamily: 'HNRegular',
        ),
      ),
      trailing: Checkbox(
        activeColor: kColorBlue,
        value: isChecked,
        onChanged: checkboxCallback,
      ),
    );
  }
}