import 'package:example/ahp/ahp_example_page.dart';
import 'package:example/saw/saw_example_page.dart';
import 'package:flutter/material.dart';

class DecisionMakingPage extends StatelessWidget {
  const DecisionMakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Decision Making'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// USING AHP FEATURE
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AhpExamplePage()),
                  ),
              child: Text(
                'Analytical Hierarchy Process',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// USING SAW FEATURE
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SawExamplePage()),
                  ),
              child: Text(
                'Sample Additive Weighting',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
