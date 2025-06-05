import 'package:flutter/material.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_scale.dart';

class PairwiseComparisonScaleWidget extends StatefulWidget {
  final List<PairwiseComparisonScale> comparison;
  final Function(PairwiseComparisonScale?, bool?) onSelected;
  final String leftItemName;
  final String rightItemName;

  const PairwiseComparisonScaleWidget({
    super.key,
    required this.comparison,
    required this.onSelected,
    required this.leftItemName,
    required this.rightItemName,
  });

  @override
  State<PairwiseComparisonScaleWidget> createState() =>
      _PairwiseComparisonScaleWidgetState();
}

class _PairwiseComparisonScaleWidgetState
    extends State<PairwiseComparisonScaleWidget> {
  final ValueNotifier<PairwiseComparisonScale?> _selectedScale = ValueNotifier(
    null,
  );
  final ValueNotifier<bool?> _isLeftMoreImportant = ValueNotifier(null);
  String? _message;

  @override
  void dispose() {
    super.dispose();
    _selectedScale.dispose();
    _isLeftMoreImportant.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(maxHeight: 400),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pairwise Comparison Scale',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              /// LIST COMPARISON
              MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ListView.builder(
                  itemCount: widget.comparison.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var data = widget.comparison[index];
                    return InkWell(
                      onTap: () {
                        _selectedScale.value = data;
                      },
                      child: ValueListenableBuilder(
                        valueListenable: _selectedScale,
                        builder: (context, v, c) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 3),
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            color:
                                _selectedScale.value == data
                                    ? Colors.grey.shade200
                                    : null,
                            child: Text(
                              '${data.value} - ${data.description}',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              /// SELECT IMPORTANT
              ValueListenableBuilder(
                valueListenable: _isLeftMoreImportant,
                builder:
                    (context, v, c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Which is more important?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ListTile(
                          title: Text(
                            widget.leftItemName,
                            style: TextStyle(fontSize: 16),
                          ),
                          leading: Radio<bool?>(
                            value: true,
                            groupValue: _isLeftMoreImportant.value,
                            onChanged: (value) {
                              _isLeftMoreImportant.value = value;
                            },
                          ),
                        ),

                        ListTile(
                          title: Text(
                            widget.rightItemName,
                            style: TextStyle(fontSize: 16),
                          ),
                          leading: Radio<bool?>(
                            value: false,
                            groupValue: _isLeftMoreImportant.value,
                            onChanged: (value) {
                              _isLeftMoreImportant.value = value;
                            },
                          ),
                        ),
                      ],
                    ),
              ),

              SizedBox(height: 10),

              /// ERROR MESSAGE
              _message != null
                  ? Text(
                    _message!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : SizedBox(),

              SizedBox(height: 10),

              /// BUTTON SAVE
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedScale.value == null) {
                      setState(() {
                        _message = 'Please select scale comparison!';
                      });
                    } else if (_isLeftMoreImportant.value == null) {
                      setState(() {
                        _message = 'Please select which more important!';
                      });
                    } else {
                      /// RETURN VALUE
                      widget.onSelected.call(
                        _selectedScale.value,
                        _isLeftMoreImportant.value,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showPairwiseComparisonScaleDialog(
  BuildContext context, {
  required List<PairwiseComparisonScale> comparison,
  required Function(PairwiseComparisonScale?, bool?) onSelected,
  required String leftItemName,
  required String rightItemName,
}) async {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'PAIRWISE COMPARISON SCALE',
    barrierDismissible: true,
    pageBuilder:
        (context, anim1, anim2) => PairwiseComparisonScaleWidget(
          comparison: comparison,
          onSelected: onSelected,
          leftItemName: leftItemName,
          rightItemName: rightItemName,
        ),
  );
}
