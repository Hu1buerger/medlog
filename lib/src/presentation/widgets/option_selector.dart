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

class VariableOption<T extends num> extends Option<T> {
  @override
  bool get fixedValue => false;

  T min;
  T max;
  T step;

  VariableOption({required T value, String? title = "custom", String? leading, num min = 0, num max = 1, num step = 1})
      : min = min as T,
        max = max as T,
        step = step as T,
        super(value: value, title: title, leading: leading);
}

class OptionSelector<T> extends StatefulWidget {
  static final Logger _logger = Logger("OptionSelector");

  Logger get logger => _logger;

  final List<Option<T>> options;
  final void Function(T value) onSelectValue;
  final int selected;

  const OptionSelector({Key? key, required this.options, required this.onSelectValue, this.selected = -1})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OptionSelectorState<T>();
}

class _OptionSelectorState<T> extends State<OptionSelector<T>> {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

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

    if (option is VariableOption) {
      // just assume that it is a double but should be changed
      return VariableOptionWidget(
        option: option as VariableOption,
        selected: selected,
        onPressed: () => onClickOnItem(index),
        onValueChange: () => onValueChange(option),
      );
    }

    return FixedOptionWidget(
      option: option,
      selected: selected,
      onPressed: () => onClickOnItem(index),
    );
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

class VariableOptionWidget<T extends num, S extends VariableOption<T>> extends StatefulWidget {
  final S option;
  final bool selected;
  final void Function()? onPressed;
  final void Function()? onValueChange;

  const VariableOptionWidget(
      {Key? key, required this.option, this.selected = false, this.onPressed, this.onValueChange})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _VariableOptionWidgetState<T, S>();
}

class _VariableOptionWidgetState<T extends num, S extends VariableOption<T>> extends State<VariableOptionWidget<T, S>> {
  VariableOption<T> get option => widget.option;

  bool get selected => widget.selected;

  late T value;

  @override
  void initState() {
    super.initState();
    value = option.value;
  }

  void setOptionValue(num value) {
    assert(option.value is T);

    if (value < option.min) value = option.min;

    if (option.value is int) {
      option.value = value.toInt() as T;
    }
    if (option.value is double) {
      option.value = value.toDouble() as T;
    }
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
            min: option.min.toDouble(),
            max: option.max.toDouble(),
            onChanged: (val) {
              value = (val - (val % option.step)) as T;
              setState(() {});
            },
            onChangeEnd: (val) {
              setOptionValue(value);
              onValue(value);
            },
          )
        ],
      );
    } else {
      return chip;
    }
  }
}
