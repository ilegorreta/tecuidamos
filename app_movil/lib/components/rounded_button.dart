import 'package:flutter/material.dart';
import 'package:tecuidamos/utilities/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton(
      {this.color,
      this.title,
      @required this.onPressed,
      this.fontFamily,
      this.flex = 1,
      this.paddingTop = 16,
      this.paddingLeft = 0,
      this.paddingRight = 0,
      this.paddingBottom = 0});

  final Color color;
  final String title;
  final Function onPressed;
  final String fontFamily;
  final int flex;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(
            top: paddingTop,
            left: paddingLeft,
            right: paddingRight,
            bottom: paddingBottom),
        child: Material(
          elevation: 7.5,
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          shadowColor: kColorShadow,
          child: MaterialButton(
            onPressed: onPressed,
            minWidth: 160.0,
            height: 42.0,
            child: AutoSizeText(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontFamily,
                fontSize: 18,
              ),
              minFontSize: 9,
              maxFontSize: 18,
              stepGranularity: 1,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
