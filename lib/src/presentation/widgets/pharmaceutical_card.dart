import 'package:flutter/material.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalCard extends StatelessWidget {
  final Pharmaceutical pharmaceutical;
  final void Function()? onLongPress;
  final double units;

  const PharmaceuticalCard({Key? key, required this.pharmaceutical, this.onLongPress, this.units = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(pharmaceutical.displayName),
          subtitle: Text("${pharmaceutical.activeSubstance} ${pharmaceutical.dosage.scale(units)}"),
          onLongPress: onLongPress),
    );
  }
}
