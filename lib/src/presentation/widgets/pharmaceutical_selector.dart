import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_filter.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_widget.dart';

class PharmaceuticalSelector extends StatefulWidget {
  final PharmaceuticalRepo pharmaceuticalController;

  final String initialQuery;

  final void Function(Pharmaceutical?) onSelectionChange;
  final void Function(String query) onSelectionFailed;

  const PharmaceuticalSelector(
      {Key? key,
      required this.pharmaceuticalController,
      required this.onSelectionChange,
      required this.onSelectionFailed,
      this.initialQuery = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PharmaceuticalSelectorState();
}

class _PharmaceuticalSelectorState extends State<PharmaceuticalSelector> {
  PharmaceuticalRepo get pharmaController => widget.pharmaceuticalController;

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
    var options = pharmaController.filter(query, PharmaceuticalFilter.all());
    logger.fine("updated current options to ${options.length}");

    setOptions(options);
  }

  void setOptions(List<Pharmaceutical> options) {
    this.options = sortPharmaceuticals(options);
    setState(() {});
  }

  /// callback to the textField
  ///
  /// These cases arent handled in setOption bcs the user should be able to fully type the query
  /// Pressing ok on the keyboard (editing complete) is okaying
  ///
  /// This handles
  ///  - no remaining options => search failed
  ///  - 1 remaining option => handle as if the user selected this option
  ///  - > 1 remaining options => just update the options
  void onEditingComplete(BuildContext context) {
    if (options.isEmpty) {
      logger.fine(
          "Editing complete with query ${searchQueryController.text} and no remaining options");
      widget.onSelectionFailed(searchQueryController.text);
      return;
    }

    var state = "";
    if (options.length == 1) {
      state = "found and selected the last remaining option";
      setPharmaceutical(options.single);
    } else if (options.isNotEmpty) {
      state = "and #${options.length} options remain";
    }

    logger.fine(
        "Editing complete with query ${searchQueryController.text} $state");
  }

  void setPharmaceutical(Pharmaceutical p) {
    logger.fine("Selecting ${p.id} ${p.displayName}");

    _updatePharmaceutical(p);
  }

  void _updatePharmaceutical(Pharmaceutical? p) {
    if (selectedPharmaceutical == p) {
      logger.finest(
          "updating the pharmaceutical selection: but selected and new are ==");
      return;
    }

    logger.fine("updating to pharma ${p?.displayName ?? "null"}");

    setState(() => selectedPharmaceutical = p);
    widget.onSelectionChange(selectedPharmaceutical);
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
                border: OutlineInputBorder(),
                hintText: 'Enter a search term:',
                prefixIcon: Icon(Icons.search)),
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

                return Card(
                  child: PharmaceuticalWidget(
                    pharmaceutical: currentItem,
                    onTap: () => setPharmaceutical(currentItem),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
