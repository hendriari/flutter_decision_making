import 'package:flutter/material.dart';

class DecisionInputValueCriteriaWidget extends StatefulWidget {
  final Function(double) onSave;

  const DecisionInputValueCriteriaWidget({super.key, required this.onSave});

  @override
  State<DecisionInputValueCriteriaWidget> createState() =>
      _DecisionInputValueCriteriaWidgetState();
}

class _DecisionInputValueCriteriaWidgetState
    extends State<DecisionInputValueCriteriaWidget> {
  final _valueController = TextEditingController();
  late TextStyle _textStyle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textStyle = TextStyle(fontSize: 16);
  }

  @override
  void dispose() {
    _valueController.dispose();
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
              /// VALUE CONTROLLER
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hint: Text('Input Value', style: _textStyle),
                  border: OutlineInputBorder(),
                ),
              ),

              /// ERROR MESSAGE
              _errorMessage != null
                  ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage!,
                      style: _textStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : const SizedBox(height: 20),

              /// BUTTON SAVE OR CLOSE
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Close", style: _textStyle),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () {
                      final value = _valueController.text.trim();

                      final valueParsed = double.tryParse(value);

                      if (valueParsed == null) {
                        _updateErrorMessage('Please input a valid number!');
                      } else {
                        widget.onSave.call(valueParsed);
                        Navigator.of(context).pop();
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

Future<bool?> showDecisionInputValueCriteriaDialog(
  BuildContext context, {
  required Function(double) onSave,
}) async {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'SAW INPUT VALUE CRITERIA',
    pageBuilder: (context, _, _) => DecisionInputValueCriteriaWidget(onSave: onSave),
  );
}
