import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class Option<T>{
  String? leading;
  String? title;

  bool fixedValue;
  T value;

  Option({required this.value, this.title, this.leading, this.fixedValue = true});

  String getTitle(){
    return title ?? (leading ?? "") + value.toString();
  }
}

class OptionSelector<T> extends StatefulWidget{
  static final Logger _logger = Logger("OptionSelector");
  Logger get logger => _logger;

  final List<Option<T>> options;
  final void Function(T value) onSelectValue;

  OptionSelector({Key? key, required this.options, required this.onSelectValue}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OptionSelectorState<T>();
}

class _OptionSelectorState<T> extends State<OptionSelector<T>>{

  int selected = 0;

  void selectItem(Option<T> option){
    var i = widget.options.indexOf(option);
    assert(i >= 0);

    if(selected == i) return;

    widget.logger.fine("selecting $i");

    selected = i;

    widget.onSelectValue(option.value);

    setState((){});
  }

  Widget buildOption(Option<T> option){
    int index = widget.options.indexOf(option);

    return FixedOptionWidget(
      option: option,
      selected: selected == index,
      onSelected: () => selectItem(option),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.logger.fine("building");

    var optionWidget = List.generate(widget.options.length, (index) {
      var optionI = widget.options[index];
      return buildOption(optionI);
    });

    return Row(
      children: optionWidget,
    );
  }
}

class FixedOptionWidget<T> extends StatelessWidget{
  final Option<T> option;
  final bool selected;
  final void Function()? onSelected;

  const FixedOptionWidget({Key? key, required this.option, this.selected = false, this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var chip = InputChip(
      label: Text(option.getTitle()),
      onPressed: onSelected ?? () => print("clicked on option ${option.getTitle()}"),
      selected: selected,
    );

    return chip;
  }
}