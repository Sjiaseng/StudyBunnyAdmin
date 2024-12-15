import 'package:flutter/material.dart';

class IncrementDecrementFormField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const IncrementDecrementFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
  });

  @override
  _IncrementDecrementFormFieldState createState() => _IncrementDecrementFormFieldState();
}
// Increment or Decrement widget 
class _IncrementDecrementFormFieldState extends State<IncrementDecrementFormField> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _value = int.tryParse(widget.controller.text) ?? 0;
    widget.controller.text = _value.toString();
  }
  // +1 to the value when pressed + button
  void _increaseValue() {
    setState(() {
      _value++;
      widget.controller.text = _value.toString();
    });
  }
  // -1 to the value when pressed - button
  void _decreaseValue() {
    setState(() {
      if (_value > 0) {
        _value--;
        widget.controller.text = _value.toString();
      }
    });
  }
  // show the data and ensure the value not lesser than 0 or equals to 0
  void _handleTextChanged(String value) {
    final int? newValue = int.tryParse(value);
    if (newValue != null && newValue >= 0) {
      setState(() {
        _value = newValue;
      });
    } else {
      widget.controller.text = _value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _decreaseValue,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _increaseValue,
            ),
          ],
        ),
      ),
      validator: widget.validator,
      onChanged: _handleTextChanged,
    );
  }
}
