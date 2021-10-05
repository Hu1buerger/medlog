import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class AddLogEntry extends StatefulWidget {
  static const String routeName = "/addMedicationIntakeLog";

  @override
  State<StatefulWidget> createState() => _AddLogEntryState();
}

class _AddLogEntryState extends State<AddLogEntry> {
  late PharmaceuticalProvider pharmaProvider = PharmaceuticalProvider.provider;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text("MedicationName:"),
        Autocomplete<Pharmaceutical>(
          optionsBuilder: (TextEditingValue tevalue) {
            return pharmaProvider.pharmaceuticals
                .where((element) => element.tradename.toLowerCase().startsWith(tevalue.text.toLowerCase()))
                .toList();
          },
          optionsViewBuilder: buildPharmaceuticalOption,
        )
      ],
    );
  }

  Widget buildPharmaceuticalOption(BuildContext context, AutocompleteOnSelected<Pharmaceutical> onSelected,
      Iterable<Pharmaceutical> options) {
    var opts = options.toList();

    return ListView.builder(
        itemCount: opts.length,
        itemBuilder: (BuildContext context, int index) {
          var pharm = opts[index];
          
          return ListTile(
            title: Text(pharm.tradename, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(pharm.dosage),
          );
        });
  }
}