import 'package:flutter/material.dart';

class TextSearchField extends StatelessWidget {
  final Function(String) onSubmitted;
  final TextEditingController? controller;

  final GlobalKey<FormFieldState> formFieldKey;

  const TextSearchField(
      {Key? key, this.controller, required this.onSubmitted, required this.formFieldKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: TextFormField(
            key: formFieldKey,
            controller: controller,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))),
            validator: (String? val) =>
                (val == null || val.isEmpty) ? 'Please enter a search term first.' : null,
            onFieldSubmitted: (value) {
              if (formFieldKey.currentState != null && formFieldKey.currentState!.validate()) {
                onSubmitted.call(value);
              }
            }),
      ),
    );
  }
}
