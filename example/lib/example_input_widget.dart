import 'package:flutter/material.dart';

class ExampleInputWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function() onPressed;

  const ExampleInputWidget({
    super.key,
    required this.title,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 18)),

        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ),

        ElevatedButton(onPressed: onPressed, child: Text('Add')),
      ],
    );
  }
}
