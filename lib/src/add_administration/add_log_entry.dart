import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/administration_log/administration_log_controller.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical_controller.dart';

/// Supports adding a logentry to the log
///
/// This Widget is supposed to handle the feature to track the intake of medications
///
/// TODO: search through the medication database notonly by tradname but also by active_substance
/// TODO: make this visualy appealing
class AddLogEntry extends StatefulWidget {
  static const String routeName = "/addMedicationIntakeLog";
  static const String title = "Add medication to log";

  late final PharmaceuticalController pharmaProvider;
  final AdministrationLogController logController;

  AddLogEntry({Key? key, PharmaceuticalController? pharmaceuticalProvider, required this.logController}) : super(key: key) {
    pharmaProvider = pharmaceuticalProvider ?? PharmaceuticalController.provider;
  }

  @override
  State<StatefulWidget> createState() => _AddLogEntryState();
}

class _AddLogEntryState extends State<AddLogEntry> {
  bool trySearch = true;
  String? medName;
  String? dosage;
  DateTime adminTime = DateTime.now();

  //Widget buildAutocompleting(BuildContext context){}

  void onCancel(BuildContext context) {
    Navigator.pop(context);
  }

  void onDone(BuildContext context) {
    if (medName == null || dosage == null) {
      return;
    }
    var pharmaceutical = widget.pharmaProvider.pharmaceuticalByNameAndDosage(medName!, dosage!);
    if (pharmaceutical == null) {
      return;
    }

    widget.logController.addLogEntry(pharmaceutical, adminTime);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text(AddLogEntry.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => onCancel(context),
            ),
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => onDone(context),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Medication:"),
            Autocomplete<Pharmaceutical>(
              displayStringForOption: (p) => "${p.tradename} ${p.dosage}",
              optionsBuilder: (TextEditingValue tevalue) {
                return widget.pharmaProvider.pharmaceuticals
                    .where((element) => element.tradename.toLowerCase().startsWith(tevalue.text.toLowerCase()))
                    .toList();
              },
              onSelected: (Pharmaceutical? p) {
                print(p?.tradename ?? "NULL");
                if(p != null){
                  medName = p.tradename;
                  dosage = p.dosage;
                }
              },
              //optionsViewBuilder: buildPharmaceuticalOption,
            ),
            const Text("Time:"),
            const Text("SUPPORTING_NOW_FOR_NOW"),
          ],
        ));
  }

  Widget buildPharmaceuticalOption(
      BuildContext context, AutocompleteOnSelected<Pharmaceutical> onSelected, Iterable<Pharmaceutical> options) {
    var opts = options.toList();

    return ListView.builder(
        itemCount: opts.length,
        itemBuilder: (BuildContext context, int index) {
          var pharm = opts[index];

          return ListTile(
            title: Text(pharm.tradename, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(pharm.dosage),
            onTap: () => onSelected(pharm),
          );
        });
  }
}
