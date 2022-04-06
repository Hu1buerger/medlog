import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class Option<T> {
  Option({required T value, this.title, this.leading}) : _value = value;

  String? leading;
  String? title;

  bool get fixedValue => true;

  late T _value;

  T get value => _value;

  String getTitle() {
    return title ?? (leading ?? "") + value.toString();
  }
}

class VariableOption<T extends num> extends Option<T> {
  VariableOption({required T value, String? title = "custom", String? leading, num min = 0, num max = 1, num step = 1})
      : min = min as T,
        max = max as T,
        step = step as T,
        assert(min >= 0),
        assert(max > min),
        assert(step > 0),
        assert(value % step == 0),
        super(value: value, title: title, leading: leading);

  @override
  bool get fixedValue => false;

  T min;
  T max;
  T step;

  set value(num val) {
    var kSteps = val / step;
    var alligned = kSteps.round();

    _value = alligned * step as T;
  }
}

//TODO: Add a onCancle / unselect callback to represent the right state
/// This widget is WIP
///  and supposed to select 1 option out of {...}.
///
/// This dosnt handle debouncing or waiting until the user has committed.
class OptionSelector<T> extends StatefulWidget {
  static final Logger _logger = Logger("OptionSelector");

  Logger get logger => _logger;

  final List<Option<T>> options;

  //TODO: Migrate to this callback bcs it is superior.
  final void Function(Option<T>? option) onSelectOption;
  final int selected;

  const OptionSelector({Key? key, required this.options, required this.onSelectOption, this.selected = -1})
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

  /// Handles selecting an option
  ///
  /// This is a result of clicking the living shit out of the item.
  void onClickOnItem(int i) {
    assert(i >= 0);

    if (selected != i) {
      // change selected item
      widget.logger.fine("selecting $i");
      var option = widget.options[i];
      selected = i;

      updateSelected(option);
    } else {
      // click on the same item
      widget.logger.fine("deselecting item");
      selected = -1;

      updateSelected(null);
    }

    setState(() {});
  }

  /// updates the selected option.
  void updateSelected(Option<T>? o) {
    widget.logger.finest("value of $o changed to ${o?.value ?? "unselected"}");
    widget.onSelectOption(o);
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
        onValueChange: () => updateSelected(option),
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
    widget.logger.fine("building with optionlist as ${identityHashCode(widget.options)}");

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
      }
    } else {
      options = List.generate(widget.options.length, (index) {
        var optionI = widget.options[index];
        return buildOption(optionI, index == selected);
      });
    }

    //FIXME: this can overflow
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
  static Logger logger = Logger("VariableOptionWidget");

  bool get selected => widget.selected;
  DateTime lastChange = DateTime.now();

  VariableOption<T> get option => widget.option;

  T get value => option.value;
  late double lowerBound;
  late double upperBound;

  @override
  void initState() {
    super.initState();

    lowerBound = option.min.toDouble();
    upperBound = lowerBound + option.step.toDouble() * 10;
    upperBound = max(option.value.toDouble(), upperBound);
  }

  /// set the value of the option model.
  ///
  /// This should be just setting the value but somehow its wierd
  ///   and typemismatched
  /// option.value = value;
  void setOptionValue(num value) {
    logger.fine("change of sliderval to $value");
    if (value < option.min) value = option.min;
    if (value > option.max) value = option.max;

    setState(() {
      option.value = value;
    });

    logger.fine(option.value);
    logger.fine(this.value);
  }

  /// commit the value the user selected
  /// and inform the callback.
  void commit() {
    if (widget.onValueChange == null) return;

    widget.onValueChange!();
  }

  void onSliderChange(double val) {
    //calculate change velocity
    num delta = value - val;

    DateTime oldChangeStamp = lastChange;
    lastChange = DateTime.now();
    Duration deltaT = oldChangeStamp.difference(lastChange);
    num vx = delta / deltaT.abs().inMilliseconds;

    //
    rescaleBounds();
    setOptionValue(val);
  }

  /// resaling the bounds of the slider
  ///
  /// The sliders min and max shall be decreased when the user is slow selecting
  ///
  /// for the impl we need
  ///  - dx
  ///  -
  void rescaleBounds() {
    double sliderLength = upperBound - lowerBound;

    // && the value is in the upper 90 % of the slider
    if (upperBound < option.max && value > lowerBound + 0.9 * sliderLength) {
      upperBound += 0.25 * sliderLength;
    }

    if (upperBound > option.max) upperBound = option.max.toDouble();
    if (upperBound < option.value) upperBound = option.value.toDouble();

    logger.fine("Updating the upper bounds to $upperBound");
  }

  @override
  Widget build(BuildContext context) {
    var chip = FixedOptionWidget(option: option, selected: selected, onPressed: widget.onPressed);

    logger.fine(identityHashCode(option));

    if (selected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          chip,
          Text("Units: $value"),
          Slider(
            value: value.toDouble(),
            min: lowerBound,
            max: upperBound,
            onChanged: onSliderChange,
            onChangeEnd: (val) => commit(),
          )
        ],
      );
    } else {
      return chip;
    }
  }
}
