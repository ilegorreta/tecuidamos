import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tecuidamos/utilities/constants.dart';

class AlertDisplay {
  AlertDisplay({
    @required this.context,
    this.onPressed1,
    this.onPressed2,
    this.title = 'Título',
    this.description = 'Descripción',
    this.button1 = 'Botón 1',
    this.button1Color = kColorPurple,
    this.button2 = 'Botón 2',
    this.button2Color = kColorPurple,
    this.buttonsQuantity = 1,
    this.mainIcon,
    this.textFieldChild,
  });

  final BuildContext context;
  final Function onPressed1;
  final Function onPressed2;
  final String title;
  final String description;
  final String button1;
  final Color button1Color;
  final Color button2Color;
  final String button2;
  final int buttonsQuantity;
  final String mainIcon;
  final Widget textFieldChild;

  Future<bool> alert() {
    AlertType type;

    switch (mainIcon) {
      case 'Error':
        type = AlertType.error;
        break;
      case 'Info':
        type = AlertType.info;
        break;
      case 'Success':
        type = AlertType.success;
        break;
      case 'Warning':
        type = AlertType.warning;
        break;
      default:
        type = AlertType.none;
    }

    if (buttonsQuantity == 1) {
      return Alert(
        context: context,
        type: type,
        closeIcon: Icon(MdiIcons.closeCircle),
        title: title,
        desc: description,
        style: kAlertStyle,
        buttons: [
          DialogButton(
            color: button1Color,
            radius: BorderRadius.circular(20.0),
            child: Text(
              button1,
              style: kAlertButtonTextStyle,
            ),
            onPressed: onPressed1,
            width: 120,
          )
        ],
      ).show();
    } else {
      return Alert(
        context: context,
        type: type,
        closeIcon: Icon(MdiIcons.closeCircle),
        title: title,
        desc: description,
        style: kAlertStyle,
        buttons: [
          DialogButton(
            color: button1Color,
            radius: BorderRadius.circular(20.0),
            child: Text(
              button1,
              style: kAlertButtonTextStyle,
            ),
            onPressed: onPressed1,
            width: 120,
          ),
          DialogButton(
            color: button2Color,
            radius: BorderRadius.circular(20.0),
            child: Text(
              button2,
              style: kAlertButtonTextStyle,
            ),
            onPressed: onPressed2,
            width: 120,
          ),
        ],
      ).show();
    }
  }

  Future<bool> alertTextField() {
    return Alert(
        context: context,
        style: kAlertStyle,
        closeIcon: Icon(MdiIcons.closeCircle),
        title: title,
        content: Column(
          children: <Widget>[
            textFieldChild,
          ],
        ),
        buttons: [
          DialogButton(
            color: kColorBlue,
            radius: BorderRadius.circular(20.0),
            onPressed: onPressed1,
            width: 120,
            child: Text(
              button1,
              textAlign: TextAlign.center,
              style: kAlertButtonTextStyle,
            ),
          )
        ]).show();
  }
}
