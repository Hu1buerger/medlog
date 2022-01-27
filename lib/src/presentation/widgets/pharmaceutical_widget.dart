import 'package:flutter/material.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalWidget extends StatelessWidget {
  final Pharmaceutical pharmaceutical;
  final double units;

  final void Function()? onTap;
  final void Function()? onLongPress;

  const PharmaceuticalWidget(
      {Key? key,
      required this.pharmaceutical,
      this.onLongPress,
      this.onTap,
      this.units = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(pharmaceutical.displayName),
        subtitle: Text("${pharmaceutical.displaySubstances} ${pharmaceutical.dosage.scale(units)}"),
        onTap: onTap,
        onLongPress: onLongPress);
  }
}
