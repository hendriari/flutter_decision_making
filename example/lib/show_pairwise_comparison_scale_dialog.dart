import 'package:flutter/material.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_scale.dart';

class PairwiseComparisonScaleWidget extends StatefulWidget {
  final List<PairwiseComparisonScale> comparison;
  final Function(PairwiseComparisonScale?) onSelected;

  const PairwiseComparisonScaleWidget({
    super.key,
    required this.comparison,
    required this.onSelected,
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

  @override
  void dispose() {
    super.dispose();
    _selectedScale.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    itemCount: widget.comparison.length,
                    shrinkWrap: true,
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
              ),
            ),

            SizedBox(height: 10),

            /// BUTTON SAVE
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelected.call(_selectedScale.value);
                  Navigator.pop(context);
                },
                child: Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showPairwiseComparisonScaleDialog(
  BuildContext context, {
  required List<PairwiseComparisonScale> comparison,
  required Function(PairwiseComparisonScale?) onSelected,
}) async {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'PAIRWISE COMPARISON',
    barrierDismissible: true,
    pageBuilder:
        (context, anim1, anim2) => PairwiseComparisonScaleWidget(
          comparison: comparison,
          onSelected: onSelected,
        ),
  );
}
