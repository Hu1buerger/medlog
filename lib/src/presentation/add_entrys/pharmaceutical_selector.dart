import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalSelector extends StatefulWidget {
  final PharmaceuticalController pharmaceuticalController;
  final void Function(Pharmaceutical?) onSelectionChange;
  final String initialQuery;

  const PharmaceuticalSelector(
      {Key? key, required this.pharmaceuticalController, required this.onSelectionChange, this.initialQuery = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PharmaceuticalSelectorState();
}

class _PharmaceuticalSelectorState extends State<PharmaceuticalSelector> {
  PharmaceuticalController get pharmaController => widget.pharmaceuticalController;

  Logger logger = Logger("Pharmaselector");
  TextEditingController searchQueryController = TextEditingController();

  List<Pharmaceutical> options = [];
  Pharmaceutical? selectedPharmaceutical;

  @override
  void initState() {
    super.initState();
    setOptions(pharmaController.pharmaceuticals);
    logger.fine("initializing with options ${options.length}");

    pharmaController.addListener(onPharmaControllerChange);
  }

  @override
  void dispose() {
    super.dispose();
    pharmaController.removeListener(onPharmaControllerChange);
  }

  /// update the options as soon as the pharmaController signals a change in data
  void onPharmaControllerChange() {
    logger.fine("change in pharmaController");
    // update the options while keeping the query the same
    updateQuery(searchQueryController.text);
  }

  List<Pharmaceutical> sortPharmaceuticals(List<Pharmaceutical> list) {
    list.sort((a, b) => a.displayName.compareTo(b.displayName));
    return list;
  }

  void updateQuery(String query) {
    var options = pharmaController.filter(query);
    logger.fine("updated current options to ${options.length}");

    setOptions(options);
  }

  void setOptions(List<Pharmaceutical> options) {
    options = sortPharmaceuticals(options);
    setState(() {});
  }

  void onEditingComplete(BuildContext context) {
    logger.fine("Editing complete with ${searchQueryController.text}");

    if (options.length == 1) {
      setPharmaceutical(options.single);
    }
    //TODO: respond with selected = 0 incase options.isEmpty
  }

  void setPharmaceutical(Pharmaceutical p) {
    logger.fine("Selecting ${p.id} ${p.displayName}");

    selectedPharmaceutical = p;
    setState(() {});
  }

  void unselectPharmaceutical() {
    if (selectedPharmaceutical == null) {
      logger.severe("unselectPharmaceutical called even though no pharmaceutical was set}");
      return;
    }

    logger.fine("Deselecting ${selectedPharmaceutical!.id} ${selectedPharmaceutical!.displayName}");
    selectedPharmaceutical = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: searchQueryController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter a search term:', prefixIcon: Icon(Icons.search)),
            autocorrect: false,
            onChanged: (value) => updateQuery(value),
            onEditingComplete: () => onEditingComplete(context),
          ),
        ),
        Expanded(
          child: Card(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                var currentItem = options[index];

                return ListTile(
                  title: Text(currentItem.displayName),
                  subtitle: Row(
                    children: [
                      Text(currentItem.activeSubstance ?? ""),
                      const SizedBox(width: 10),
                      Text(currentItem.dosage.toString())
                    ],
                  ),
                  onTap: () => setPharmaceutical(currentItem),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
