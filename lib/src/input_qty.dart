import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum BorderShapeBtn {
  none,
  circle,
  // square, // on development
  //rhombus  // on development
}

class InputQty extends StatefulWidget {
  /// maximum value input
  /// default  `maxVal = num.maxFinite`,
  final num maxVal;

  /// intial value
  /// default `initVal = 0`
  /// To show decimal number, set `initVal` with decimal format
  /// eg: `initVal = 0.0`
  ///
  final num initVal;

  /// minimum value
  /// default `minVal = 0`
  final num minVal;

  /// steps increase and decrease
  /// defalult `steps = 1`
  /// also support for decimal steps
  /// eg: `steps = 3.14`
  final num steps;

  /// ```dart
  /// Function(num? value) onChanged
  /// ```
  /// update value every changes
  /// the `runType` is `num`.
  /// parse to `int` : `value.toInt();`
  /// parse to `double` : `value.toDouble();`
  final ValueChanged<num?> onQtyChanged;

  /// wrap [TextFormField] with [IntrinsicWidth] widget
  /// this will make the width of [InputQty] set to intrinsic width
  /// default  `isIntrinsicWidth = true`
  /// if `false` wrapped with `Expanded`
  final bool isIntrinsicWidth;

  /// Custom decoration of [TextFormField]
  /// default value:
  ///```dart
  /// const InputDecoration(
  ///  border: UnderlineInputBorder(),
  ///  isDense: true,
  ///  isCollapsed: true,)
  ///```
  /// add [contentPadding] to costumize distance between value
  /// and the button
  final InputDecoration? textFieldDecoration;

  /// custom icon for button plus
  final Widget? plusBtn;

  /// Custom icon for button minus
  /// default size is 16
  final Widget? minusBtn;

  /// button color
  /// availabe to press
  final Color btnColor1;

  /// button color 2
  /// not able to press
  final Color btnColor2;

  /// spalsh radius effect
  /// default = 16
  final double? splashRadius;

  /// border shape of button
  /// - none
  /// - circle
  final BorderShapeBtn borderShape;

  const InputQty({
    Key? key,
    this.initVal = 0,
    this.borderShape = BorderShapeBtn.circle,
    this.splashRadius,
    this.textFieldDecoration,
    this.isIntrinsicWidth = true,
    required this.onQtyChanged,
    this.maxVal = double.maxFinite,
    this.minVal = 0,
    this.plusBtn,
    this.minusBtn,
    this.steps = 1,
    this.btnColor1 = Colors.green,
    this.btnColor2 = Colors.grey,
  }) : super(key: key);

  @override
  State<InputQty> createState() => _InputQtyState();
}

class _InputQtyState extends State<InputQty> {
  /// text controller of textfield
  TextEditingController _valCtrl = TextEditingController();

  /// current value of quantity
  /// late num value;
  late ValueNotifier<num?> currentval;
  late ValueNotifier<bool> limitMaxVal;

  /// [InputDecoration] use for [TextFormField]
  /// use when [textFieldDecoration] not null
  final _inputDecoration = const InputDecoration(
    border: UnderlineInputBorder(),
    isDense: true,
    isCollapsed: true,
  );
  @override
  void initState() {
    currentval = ValueNotifier(widget.initVal);
    // limitMaxVal = ValueNotifier(widget.initVal == widget.maxVal);
    _valCtrl = TextEditingController(text: "${widget.initVal}");
    widget.onQtyChanged(num.tryParse(_valCtrl.text));
    super.initState();
  }

  /// Increase current value
  /// based on steps
  /// default [steps] = 1
  /// When the current value is empty string, and press [plus] button
  /// then firstly, it set the [value]= [initVal],
  /// after that [value] += [steps]
  void plus() {
    num value = num.tryParse(_valCtrl.text) ?? widget.initVal;

    if (value < widget.maxVal) {
      value += widget.steps;
      currentval.value = value;
    } else {
      value = widget.maxVal;
      currentval.value = value;
    }

    /// set back to the controller
    _valCtrl.text = "$value";

    /// move cursor to the right side
    _valCtrl.selection =
        TextSelection.fromPosition(TextPosition(offset: _valCtrl.text.length));
    widget.onQtyChanged(num.tryParse(value.toString()));
  }

  /// decrese current value based on stpes
  /// default [steps] = 1
  /// When the current [value] is empty string, and press [minus] button
  /// then firstly, it set the [value]= [initVal],
  /// after that [value] -= [steps]
  void minus() {
    num value = num.tryParse(_valCtrl.text) ?? widget.initVal;

    if (value > widget.minVal) {
      value -= widget.steps;
      currentval.value = value;
    } else {
      value = widget.minVal;
      currentval.value = value;
    }

    /// set back to the controller
    _valCtrl.text = "$value";

    /// move cursor to the right side
    _valCtrl.selection =
        TextSelection.fromPosition(TextPosition(offset: _valCtrl.text.length));
    widget.onQtyChanged(num.tryParse(value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    print('Rebuild all...');
    return widget.isIntrinsicWidth
        ? IntrinsicWidth(child: _buildInputQty())
        : _buildInputQty();
  }

  /// build widget input quantity
  Widget _buildInputQty() => Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.8),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BuildBtn(
              btnColor: widget.btnColor1,
              isPlus: false,
              borderShape: widget.borderShape,
              splashRadius: widget.splashRadius,
              onChanged: minus,
              child: widget.minusBtn,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(child: _buildtextfield()),
            const SizedBox(
              width: 8,
            ),
            ValueListenableBuilder<num?>(
                valueListenable: currentval,
                builder: (context, value, child) {
                  bool limitState = (value ?? widget.initVal) < widget.maxVal;
                  return BuildBtn(
                    btnColor: limitState ? widget.btnColor1 : widget.btnColor2,
                    isPlus: true,
                    borderShape: widget.borderShape,
                    onChanged: limitState ? plus : null,
                    splashRadius: widget.splashRadius,
                    child: widget.plusBtn,
                  );
                }),
          ],
        ),
      );

  /// widget textformfield
  Widget _buildtextfield() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: TextFormField(
          textAlign: TextAlign.center,
          decoration: widget.textFieldDecoration ?? _inputDecoration,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          controller: _valCtrl,
          onChanged: (String strVal) {
            num? temp = num.tryParse(_valCtrl.text);
            if (temp == null) return;
            if (temp > widget.maxVal) {
              temp = widget.maxVal;
              _valCtrl.text = "${widget.maxVal}";
              _valCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _valCtrl.text.length));
            } else if (temp <= widget.minVal) {
              temp = widget.minVal;
              _valCtrl.text = temp.toString();
              _valCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _valCtrl.text.length));
            }
            num? newVal = num.tryParse(_valCtrl.text);
            widget.onQtyChanged(newVal);
            currentval.value = newVal;
          },
          keyboardType: TextInputType.number,
          inputFormatters: [
            // LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\-?\d*")),
          ],
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _valCtrl.dispose();
  }
}

class BuildBtn extends StatelessWidget {
  final Widget? child;
  final Function()? onChanged;
  final bool isPlus;
  final Color btnColor;
  final double? splashRadius;

  final BorderShapeBtn borderShape;

  const BuildBtn({
    super.key,
    this.splashRadius,
    this.borderShape = BorderShapeBtn.circle,
    required this.isPlus,
    this.onChanged,
    this.btnColor = Colors.teal,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: borderShape == BorderShapeBtn.none
            ? null
            : Border.all(color: btnColor),
        borderRadius: borderShape == BorderShapeBtn.circle
            ? BorderRadius.circular(300)
            : null,
      ),
      child: IconButton(
        color: btnColor,
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        onPressed: onChanged,
        splashRadius: splashRadius ?? 16,
        icon: child ?? Icon(isPlus ? Icons.add : Icons.remove, size: 16),
      ),
    );
  }
}
