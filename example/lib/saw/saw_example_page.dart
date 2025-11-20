import 'package:flutter/material.dart';

class SawExamplePage extends StatelessWidget {
  const SawExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Sample Additive Weighting'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(
            children: [

            Text(''),


            ],
          ),
        ),
      ),
    );
  }
}
