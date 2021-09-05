import 'package:flutter/material.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppBarDecoration extends StatelessWidget implements PreferredSizeWidget {
  AppBarDecoration({this.title, this.onPressedIcon, this.returnIcon = true});
  final String title;
  final Function onPressedIcon;
  final bool returnIcon;

  @override
  Size get preferredSize {
    try {
      return Size.fromHeight(55.0);
    } catch (e) {
      throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'MPLight',
          fontWeight: FontWeight.w900,
        ),
      ),
      backgroundColor: kColorPurple,
      actions: <Widget>[
        IconButton(
          icon: Icon(MdiIcons.logout),
          onPressed: onPressedIcon,
        ),
      ],
      //Flecha de retorno que se encuentra activa implicitamente
      automaticallyImplyLeading: returnIcon,
    );
  }
}
