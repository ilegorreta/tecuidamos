import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const kDarkMainBackground = Color(0xFF141323);
const kDarkSecondaryBackground = Color(0xFF1B1A33);
const kColorPurple = Color(0xFF663BFB);
const kColorRed = Color(0xFFFB295D);
const kColorGreen = Color(0xFF10DA94);
const kColorBlue = Color(0xFF187AF2);
const kColorYellow = Color(0xFFFF8F00);
const kColorGreyHint = Color(0xFFA0A0A0);
const kColorShadow = Colors.black38;

const kAlertStyle = AlertStyle(
  backgroundColor: kDarkMainBackground,
  titleStyle: TextStyle(
    color: Colors.white,
    fontFamily: 'HNBold',
    fontSize: 20,
  ),
  descStyle: TextStyle(
    color: Colors.white,
    fontFamily: 'HNRegular',
    fontSize: 15,
  ),
  // isCloseButton: false,
);

const kAlertButtonTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontFamily: 'HNRegular',
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.only(top: 10, left: 20, right: 5, bottom: 10),
  hintText: 'Escribe tu mensaje...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  color: kDarkSecondaryBackground,
  border: Border(
    top: BorderSide(color: kColorPurple, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: kDarkSecondaryBackground,
  hintText: 'Ingresa un valor',
  hintStyle: TextStyle(
    fontFamily: 'HNRegular',
    color: kColorGreyHint,
  ),
  labelStyle: TextStyle(
    fontFamily: 'HNRegular',
    color: Colors.white,
  ),
  contentPadding: EdgeInsets.symmetric(
    vertical: 10.0,
    horizontal: 20.0,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: kDarkSecondaryBackground,
      width: 1.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: kDarkSecondaryBackground,
      width: 2.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
