import 'package:example/example_input_widget.dart';
import 'package:example/helper.dart';
import 'package:example/show_decision_input_criteria_dialog.dart';
import 'package:example/show_decision_input_value_criteria_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decision_making/feature/topsis/presentation/topsis.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';

class TopsisExamplePage extends StatefulWidget {
  const TopsisExamplePage({super.key});

  @override
  State<TopsisExamplePage> createState() => _TopsisExamplePageState();
}

class _TopsisExamplePageState extends State<TopsisExamplePage> {
  final _criteriaController = TextEditingController();
  final _alternativeController = TextEditingController();
  late TextStyle _textStyle;
  late List<WeightedDecisionAlternative> _listTopsisAlternative;
  late List<WeightedDecisionCriteria> _listTopsisCriteria;
  TopsisRawMatrix? _topsisMatrix;
  List<WeightedDecisionResult>? _topsisResult;
  late TOPSIS _topsis;
  late Helper _helper;

  @override
  void initState() {
    super.initState();
    _topsis = TOPSIS();
    _textStyle = TextStyle(fontSize: 18);
    _listTopsisAlternative = [];
    _listTopsisCriteria = [];
    _helper = Helper();
  }

  @override
  void dispose() {
    _criteriaController.dispose();
    _alternativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('TOPSIS'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(
            children: [
              /// ADD TOPSIS ALTERNATIVE
              ExampleInputWidget(
                title: 'Alternative',
                controller: _alternativeController,
                onPressed:
                    () => _addItem(
                      _alternativeController,
                      _listTopsisAlternative,
                      (name) => WeightedDecisionAlternative(name: name),
                    ),
              ),

              /// LIST TOPSIS ALTERNATIVE
              _buildListAlternativeWidget(),

              /// CRITERIA
              _buildCriteriaWidget(),

              /// LIST CRITERIA
              _buildListCriteriaWidget(),

              /// BUTTON GENERATE TOPSIS MATRIX
              _buildButtonGenerateMatrixWidget(),

              /// LIST TOPSIS MATRIX
              _buildListMatrixWidget(),

              /// BUTTON CALCULATE RESULT
              _buildButtonCalculateResultWidget(),

              /// TOPSIS RESULT
              _buildTopsisResultWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// BUILD CRITERIA
  Widget _buildCriteriaWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Criteria', style: _textStyle),

        /// DETAIL CRITERIA LIST
        Expanded(
          child: InkWell(
            onTap: () {
              showDecisionInputCriteriaDialog(
                context,
                onSave: (value) {
                  setState(() {
                    _listTopsisCriteria.add(value);
                  });
                },
              );
            },
            child: Container(
              height: 55,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
            ),
          ),
        ),

        /// ADD
        ElevatedButton(
          onPressed: () {
            showDecisionInputCriteriaDialog(
              context,
              onSave: (value) {
                setState(() {
                  _listTopsisCriteria.add(value);
                });
              },
            );
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  void _addItem<T>(
    TextEditingController controller,
    List<T> items,
    T Function(String name) createItem,
  ) {
    final value = controller.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        items.add(createItem(value));
        controller.clear();
      });
    }
  }

  /// BUILD LIST ALTERNATIVE
  Widget _buildListAlternativeWidget() {
    return _listTopsisAlternative.isNotEmpty
        ? Container(
          constraints: BoxConstraints(maxHeight: 100),
          margin: EdgeInsets.only(bottom: 10, top: 10),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: double.infinity,
          child: Scrollbar(
            child: ListView.builder(
              itemCount: _listTopsisAlternative.length,
              itemBuilder: (context, index) {
                final data = _listTopsisAlternative[index];
                return Text('${index + 1}. ${data.name}', style: _textStyle);
              },
            ),
          ),
        )
        : const SizedBox(height: 10);
  }

  /// BUILD LIST CRITERIA
  Widget _buildListCriteriaWidget() {
    return _listTopsisCriteria.isNotEmpty
        ? Container(
          constraints: BoxConstraints(maxHeight: 200),
          margin: EdgeInsets.only(bottom: 10, top: 10),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: double.infinity,
          child: Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _listTopsisCriteria.length,
              itemBuilder: (context, index) {
                final data = _listTopsisCriteria[index];
                return Column(
                  children: [
                    /// DETAIL CRITERIA
                    Table(
                      columnWidths: {
                        0: FlexColumnWidth(.4),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        _buildCommonTableRow(
                          title: 'Name',
                          value: ': ${data.name}',
                        ),
                        _buildCommonTableRow(
                          title: 'Is Benefit',
                          value: ': ${data.isBenefit}',
                        ),
                        _buildCommonTableRow(
                          title: 'Weight',
                          value: ': ${data.weightPercent}%',
                        ),
                        _buildCommonTableRow(
                          title: 'Max. Value',
                          value: ': ${data.maxValue}',
                        ),
                        _buildCommonTableRow(
                          title: 'Description',
                          value: ': ${data.description}',
                        ),
                      ],
                    ),

                    const Divider(),
                  ],
                );
              },
            ),
          ),
        )
        : const SizedBox(height: 10);
  }

  /// BUTTON GENERATE MATRIX WIDGET
  Widget _buildButtonGenerateMatrixWidget() {
    return ElevatedButton(
      onPressed: () async {
        _topsisMatrix = await _topsis
            .generateTopsisMatrix(
              listAlternative: _listTopsisAlternative,
              listCriteria: _listTopsisCriteria,
            )
            .catchError((e) {
              if (mounted) {
                _helper.showScaffoldMessenger(
                  context: context,
                  message: e.toString(),
                );
              }

              return TopsisRawMatrix(criterias: [], matrixs: []);
            });

        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {});
        });
      },
      child: Text(
        'Generate TOPSIS Matrix',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// BUILD LIST MATRIX WIDGET
  Widget _buildListMatrixWidget() {
    return _topsisMatrix != null &&
            (_topsisMatrix?.matrixs != null &&
                _topsisMatrix!.matrixs.isNotEmpty)
        ? Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                'TOPSIS Raw Matrix',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              /// LIST MATRIX
              Container(
                height: 300,
                color: Colors.grey.shade300,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: _topsisMatrix?.matrixs.length ?? 0,
                    padding: EdgeInsets.only(right: 10),
                    itemBuilder: (context, index) {
                      final data = _topsisMatrix?.matrixs[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ALTERNATIVE
                          Text(
                            '${data?.alternative.name}',
                            style: _textStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),

                          const Divider(),

                          /// HEADER TABLE
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                children: [
                                  /// CRITERIA
                                  TableCell(
                                    child: Text(
                                      'Criteria\nName',
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  /// COST OR BENEFIT
                                  TableCell(
                                    child: Text(
                                      "Is\nBenefit",
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  /// MAX VALUE FOR CRITERIA
                                  TableCell(
                                    child: Text(
                                      "Max. Value",
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  /// RATING VALUE
                                  TableCell(
                                    child: Text(
                                      "Value",
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          /// RATING
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: List.generate(data?.ratings.length ?? 0, (
                              subIndex,
                            ) {
                              final ratings = data?.ratings[subIndex];
                              return TableRow(
                                children: [
                                  /// CRITERIA
                                  TableCell(
                                    child: Text(
                                      ratings?.criteria?.name ?? '-',
                                      style: _textStyle,
                                    ),
                                  ),

                                  /// COST OR BENEFIT
                                  TableCell(
                                    child: Text(
                                      "${ratings?.criteria?.isBenefit}",
                                      style: _textStyle,
                                    ),
                                  ),

                                  /// MAX VALUE FOR CRITERIA
                                  TableCell(
                                    child: Text(
                                      "${ratings?.criteria?.maxValue}",
                                      style: _textStyle,
                                    ),
                                  ),

                                  /// RATING VALUE
                                  TableCell(
                                    child: InkWell(
                                      onTap: () {
                                        showDecisionInputValueCriteriaDialog(
                                          context,
                                          onSave: (value) async {
                                            if (_topsisMatrix != null) {
                                              _topsisMatrix = await _topsis
                                                  .updateTopsisMatrix(
                                                    currentRawMatrix:
                                                        _topsisMatrix!,
                                                    matrixId: data?.id,
                                                    ratingsId: ratings?.id,
                                                    value: value,
                                                  );

                                              setState(() {});
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 35,
                                        width: double.infinity,
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Text(
                                          '${ratings?.value}',
                                          style: _textStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),

                          Divider(color: Colors.white, thickness: 2),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        )
        : const SizedBox();
  }

  /// CALCULATE RESULT
  Widget _buildButtonCalculateResultWidget() {
    return _topsisMatrix != null &&
            (_topsisMatrix?.matrixs != null &&
                _topsisMatrix!.matrixs.isNotEmpty)
        ? ElevatedButton(
          onPressed: () async {
            _topsisResult = await _topsis
                .getTopsisResult(matrix: _topsisMatrix!)
                .catchError((e) {
                  if (mounted) {
                    _helper.showScaffoldMessenger(
                      context: context,
                      message: e.toString(),
                    );
                  }

                  return <WeightedDecisionResult>[];
                });

            Future.delayed(Duration(milliseconds: 300), () {
              setState(() {});
            });
          },
          child: Text(
            'Calculate TOPSIS Result',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
        : const SizedBox();
  }

  /// TOPSIS RESULT
  Widget _buildTopsisResultWidget() {
    return _topsisResult != null && _topsisResult!.isNotEmpty
        ? Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER TABLE
              Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      /// CRITERIA
                      TableCell(
                        child: Text(
                          'Alternative\nName',
                          style: _textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// SCORE
                      TableCell(
                        child: Text(
                          "Score",
                          style: _textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// RANKING
                      TableCell(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Ranking",
                            style: _textStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// LIST MATRIX
              Container(
                constraints: BoxConstraints(maxHeight: 300, minHeight: 100),
                color: Colors.grey.shade300,
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _topsisResult?.length ?? 0,
                    padding: EdgeInsets.only(right: 10),
                    itemBuilder: (context, index) {
                      final data = _topsisResult?[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// RESULT
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                children: [
                                  /// CRITERIA
                                  TableCell(
                                    child: Text(
                                      data?.alternative.name ?? '-',
                                      style: _textStyle,
                                    ),
                                  ),

                                  /// SCORE
                                  TableCell(
                                    child: Text(
                                      "${data?.score}",
                                      style: _textStyle,
                                    ),
                                  ),

                                  /// RANKING
                                  TableCell(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${data?.rank}",
                                        style: _textStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Divider(color: Colors.white, thickness: 2),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        )
        : const SizedBox();
  }

  /// COMMON TABLE ROW
  TableRow _buildCommonTableRow({
    required String title,
    required String value,
  }) {
    return TableRow(
      children: [
        TableCell(child: Text(title, style: _textStyle)),
        TableCell(child: Text(value, style: _textStyle)),
      ],
    );
  }
}
