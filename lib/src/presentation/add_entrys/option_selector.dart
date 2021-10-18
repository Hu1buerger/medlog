import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class Option<T> {
  String? leading;
  String? title;

  bool get fixedValue => true;
  T value;

  Option({required this.value, this.title, this.leading});

  String getTitle() {
    return title ?? (leading ?? "") + value.toString();
  }
}

class VariableOption extends Option<num> {
  @override
  bool get fixedValue => false;

  double min;
  double max;
  double step;

  VariableOption({required value, title, leading, this.min = 0, this.max = 1, this.step = 0.1})
      : super(value: value, title: title, leading: leading);
}

class OptionSelector<T> extends StatefulWidget {
  static final Logger _logger = Logger("OptionSelector");

  Logger get logger => _logger;

  final List<Option<T>> options;
  final void Function(T value) onSelectValue;

  const OptionSelector({Key? key, required this.options, required this.onSelectValue}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OptionSelectorState<T>();
}

class _OptionSelectorState<T> extends State<OptionSelector<T>> {
  int selected = 0;

  void onClickOnItem(int i) {
    assert(i >= 0);

    if (selected != i) {
      // change selected item
      var option = widget.options[i];
      widget.logger.fine("selecting $i");
      selected = i;

      onValueChange(option);
    } else {
      // click on the same item
      widget.logger.fine("deselecting item");
      selected = -1;
    }

    setState(() {});
  }

  void onValueChange(Option o) {
    widget.onSelectValue(o.value);
  }

  Widget buildOption(Option<T> option, bool selected) {
    int index = widget.options.indexOf(option);
    assert(index >= 0);

    if (option.fixedValue) {
      return FixedOptionWidget(
        option: option,
        selected: selected,
        onPressed: () => onClickOnItem(index),
      );
    } else {
      // just assume that it is a double but should be changed
      return VariableOptionWidget(
        option: option as VariableOption,
        selected: selected,
        onPressed: () => onClickOnItem(index),
        onValueChange: () => onValueChange(option),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.logger.fine("building");

    //var size = context.size;
    List<Widget> options;

    if (selected != -1) {
      // display one item left and one item right;
      const delta = 1;

      int start = selected - delta;
      int end = selected + delta;

      if (start < 0) {
        int missing = 0 - start;
        start = 0;
        // shift the end to keep (delta * 2) + 1 items on the screen
        end += missing;
      }
      if (end >= widget.options.length) end = widget.options.length - 1;

      if (start >= end) throw StateError("no items to display");

      options = [];
      for (int i = start; i <= end; i++) {
        var optionI = widget.options[i];
        bool isSelected = selected == i;

        options.add(Expanded(flex: isSelected ? 3 : 1, child: buildOption(optionI, isSelected)));
        //options.add(buildOption(optionI, isSelected));
      }
    } else {
      options = List.generate(widget.options.length, (index) {
        var optionI = widget.options[index];
        return buildOption(optionI, index == selected);
      });
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: options,
    );
  }
}

class FixedOptionWidget<S, T extends Option<S>> extends StatelessWidget {
  final T option;
  final bool selected;
  final void Function()? onPressed;

  const FixedOptionWidget({Key? key, required this.option, this.selected = false, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var chip = InputChip(
      label: Text(option.getTitle()),
      onPressed: onPressed ?? () => print("clicked on option ${option.getTitle()}"),
      selected: selected,
    );

    return chip;
  }
}

class VariableOptionWidget extends StatefulWidget {
  final VariableOption option;
  final bool selected;
  final void Function()? onPressed;
  final void Function()? onValueChange;

  const VariableOptionWidget(
      {Key? key, required this.option, this.selected = false, this.onPressed, this.onValueChange})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _VariableOptionWidgetState();
}

class _VariableOptionWidgetState extends State<VariableOptionWidget> {
  VariableOption get option => widget.option;

  bool get selected => widget.selected;

  late num value;

  @override
  void initState() {
    super.initState();
    value = option.value;
  }

  void onValue(num value) {
    if (widget.onValueChange == null) return;
    widget.onValueChange!();
  }

  @override
  Widget build(BuildContext context) {
    var chip = FixedOptionWidget(option: option, selected: selected, onPressed: widget.onPressed);

    if (selected) {
      option.value = option.value < option.min ? option.min : option.value;

      //TODO: dynamically expand max
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          chip,
          Text("Units: $value"),
          Slider(
            value: value.toDouble(),
            min: option.min,
            max: option.max,
            onChanged: (val) {
              value = val - (val % option.step);
              setState(() {});
            },
            onChangeEnd: (val) {
              option.value = value;
              onValue(val);
            },
          )
        ],
      );
    } else {
      return chip;
    }
  }
}
