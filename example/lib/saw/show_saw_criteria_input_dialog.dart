import 'package:flutter/material.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';

class SawCriteriaInputWidget extends StatefulWidget {
  final Function(SawCriteria) onSave;

  const SawCriteriaInputWidget({super.key, required this.onSave});

  @override
  State<SawCriteriaInputWidget> createState() => _SawCriteriaInputWidgetState();
}

class _SawCriteriaInputWidgetState extends State<SawCriteriaInputWidget> {
  final _nameController = TextEditingController();
  final ValueNotifier<bool?> _isBenefit = ValueNotifier(null);
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TextStyle _textStyle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textStyle = TextStyle(fontSize: 16);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _isBenefit.dispose();
    super.dispose();
  }

  void _updateErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(maxHeight: 600),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// NAME
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hint: Text('Criteria Name', style: _textStyle),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              /// TITLE COST OR BENEFIT
              Text('This is cost or benefit?', style: _textStyle),

              /// COST OR BENEFIT
              ValueListenableBuilder(
                valueListenable: _isBenefit,
                builder: (context, value, _) {
                  return RadioGroup<bool?>(
                    onChanged: (newValue) {
                      _isBenefit.value = newValue;
                    },
                    groupValue: value,
                    child: Column(
                      children: [
                        /// IS COST
                        RadioListTile<bool?>(
                          value: false,
                          title: Text('Cost', style: _textStyle),
                        ),

                        /// IS BENEFIT
                        RadioListTile<bool?>(
                          value: true,
                          title: Text('Benefit', style: _textStyle),
                        ),
                      ],
                    ),
                  );
                },
              ),

              /// WEIGHT
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hint: Text('Criteria Weight', style: _textStyle),
                  suffix: Text("%", style: _textStyle),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              /// DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hint: Text('Description', style: _textStyle),
                  border: OutlineInputBorder(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child:
                    _errorMessage != null
                        ? Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                        : const SizedBox(),
              ),

              const SizedBox(height: 10),

              /// BUTTON SAVE OR CLOSE
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Close", style: _textStyle),
                  ),

                  SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final weight = _weightController.text.trim();
                      final description = _descriptionController.text.trim();

                      if (name.isEmpty) {
                        _updateErrorMessage("Name criteria can't be empty!");
                      } else if (weight.isEmpty) {
                        _updateErrorMessage("Please input weight of criteria");
                      } else if (_isBenefit.value == null) {
                        _updateErrorMessage(
                          "Please select criteria cost or benefit",
                        );
                      } else {
                        final weightParsed = double.tryParse(weight);

                        if (weightParsed == null) {
                          _updateErrorMessage("Please input valid a number");
                        } else if (weightParsed > 100) {
                          _updateErrorMessage(
                            "the total weight must be less than 100",
                          );
                        } else if (weightParsed < 0) {
                          _updateErrorMessage(
                            "The total weight must not be a negative number",
                          );
                        } else {
                          final criteria = SawCriteria(
                            name: name,
                            isBenefit: _isBenefit.value!,
                            weightPercent: weightParsed,
                            description: description,
                          );

                          widget.onSave.call(criteria);

                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text("Save", style: _textStyle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showSawCriteriaInputDialog(
  BuildContext context, {
  required Function(SawCriteria) onSave,
}) async {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'SAW CRITERIA INPUT DIALOG',
    barrierDismissible: false,
    pageBuilder: (context, _, _) {
      return SawCriteriaInputWidget(onSave: onSave);
    },
  );
}
