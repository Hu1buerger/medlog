import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';

class AddPharmaceutical extends StatefulWidget {
  static const String routeName = "Add_Pharmaceutical";

  final APIProvider provider;

  PharmaceuticalRepo get pharmController => provider.pharmaRepo;

  const AddPharmaceutical({Key? key, required this.provider}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddPharmaceuticalState();
}

class _AddPharmaceuticalState extends State<AddPharmaceutical> {
  static const String title = "Add pharmaceutical";

  final Logger logger = Logger("AddPharmaceuticalState");

  final _formKey = GlobalKey<FormState>();

  var medicationNameCrtl = TextEditingController();
  var dosageCrtl = TextEditingController();
  var activeSubstCrtl = TextEditingController();

  void onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate() == false) return;

    var humanKnownName = medicationNameCrtl.text;
    var dosage = Dosage.parse(dosageCrtl.text);

    //TODO: allow for grouping of pharmaceuticals. This was introduced by tradename, but is retired for now
    var p = Pharmaceutical(
      changeTime: DateTime.now(),
      tradename: humanKnownName,
      substances: [activeSubstCrtl.text], //TODO allow for multiple substances
      dosage: dosage,
    );

    logger.info("submitting $p");
    widget.pharmController.createPharmaceutical(p);

    Navigator.pop(context);
  }

  void onReset(BuildContext context) {
    if (_formKey.currentState == null) throw Error();
    _formKey.currentState!.reset();
  }

  String? medNameValidator(String? value) {
    if (value == null || value.isEmpty) return "Illegal medication name";
    return null;
  }

  String? dosageValidator(String? value) {
    if (value == null || value.isEmpty) return "Illegal dosage name";
    if (["mg", "ng", "g", "ug", "IU"].any((unit) => value.contains(unit)) ==
        false) return "Illegal dosage, use unit";

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined),
            onPressed: () => onReset(context),
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () => onSubmit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                TextFormField(
                  controller: medicationNameCrtl,
                  decoration: const InputDecoration(
                    hintText: "Medicationname:",
                    border: OutlineInputBorder(),
                  ),
                  validator: medNameValidator,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: activeSubstCrtl,
                  decoration: const InputDecoration(
                      hintText: "Activesubstance:",
                      border: OutlineInputBorder()),
                  validator: medNameValidator,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: dosageCrtl,
                  decoration: const InputDecoration(
                      hintText: "Dosage:", border: OutlineInputBorder()),
                  validator: dosageValidator,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text("Cancel"),
                      onPressed: () => onReset(context),
                    ),
                    ElevatedButton(
                      child: const Text("Submit"),
                      onPressed: () => onSubmit(context),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
