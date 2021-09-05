import 'package:flutter/material.dart';

//Esto se logro extrayendo la widget desde el Flutter Outline
class ReusableCard extends StatelessWidget {
  //Se quito el constructor original porque no se queria constante, se debia modificar
  //Al ser una propiedad child, no es requisito que el usuario la llene
  ReusableCard({@required this.colour, this.cardChild, this.onPress});

  //Se anade la palabra final para especificar que es inmutable
  final Color colour;
  final Widget cardChild;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: cardChild,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}