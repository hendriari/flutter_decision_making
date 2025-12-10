import 'package:example/example_input_widget.dart';
import 'package:example/helper.dart';
import 'package:example/saw/show_saw_criteria_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decision_making/feature/saw/presentation/saw.dart';

class SawExamplePage extends StatefulWidget {
  const SawExamplePage({super.key});

  @override
  State<SawExamplePage> createState() => _SawExamplePageState();
}

class _SawExamplePageState extends State<SawExamplePage> {
  final _criteriaController = TextEditingController();
  final _alternativeController = TextEditingController();
  late TextStyle _textStyle;
  late List<SawAlternative> _listSawAlternative;
  late List<SawCriteria> _listSawCriteria;
  List<SawMatrix>? _sawMatrix;
  List<SawResult>? _sawResult;
  late SAW _saw;
  late Helper _helper;

  @override
  void initState() {
    super.initState();
    _saw = SAW();
    _textStyle = TextStyle(fontSize: 18);
    _listSawAlternative = [];
    _listSawCriteria = [];
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
        title: Text('Sample Additive Weighting'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(
            children: [
              /// ADD SAW ALTERNATIVE
              ExampleInputWidget(
                title: 'Alternative',
                controller: _alternativeController,
                onPressed:
                    () => _addItem(
                      _alternativeController,
                      _listSawAlternative,
                      (name) => SawAlternative(name: name),
                    ),
              ),

              /// LIST SAW ALTERNATIVE
              _listSawAlternative.isNotEmpty
                  ? Container(
                    constraints: BoxConstraints(maxHeight: 100),
                    margin: EdgeInsets.only(bottom: 10, top: 10),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    width: double.infinity,
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: _listSawAlternative.length,
                        itemBuilder: (context, index) {
                          final data = _listSawAlternative[index];
                          return Text(
                            '${index + 1}. ${data.name}',
                            style: _textStyle,
                          );
                        },
                      ),
                    ),
                  )
                  : const SizedBox(height: 10),

              /// CRITERIA
              _buildCriteriaWidget(),

              /// LIST CRITERIA
              _listSawCriteria.isNotEmpty
                  ? Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    margin: EdgeInsets.only(bottom: 10, top: 10),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    width: double.infinity,
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _listSawCriteria.length,
                        itemBuilder: (context, index) {
                          final data = _listSawCriteria[index];
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
                  : const SizedBox(height: 10),

              /// BUTTON GENERATE SAW MATRIX
              ElevatedButton(
                onPressed: () async {
                  _sawMatrix = await _saw
                      .generateSawMatrix(
                        listAlternative: _listSawAlternative,
                        listCriteria: _listSawCriteria,
                      )
                      .catchError((e) {
                        if (context.mounted) {
                          _helper.showScaffoldMessenger(
                            context: context,
                            message: e.toString(),
                          );
                        }

                        return <SawMatrix>[];
                      });

                  Future.delayed(Duration(milliseconds: 300), () {
                    setState(() {});
                  });
                },
                child: Text(
                  'Generate SAW Matrix',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              /// SAW MATRIX
              _sawMatrix != null && _sawMatrix!.isNotEmpty
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
                          'SAW Matrix',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        /// LIST MATRIX
                        Container(
                          height: 300,
                          color: Colors.grey.shade300,
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: _sawMatrix?.length ?? 0,
                              padding: EdgeInsets.only(right: 10),
                              itemBuilder: (context, index) {
                                final data = _sawMatrix?[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// ALTERNATIVE
                                    Text(
                                      data?.alternative.name ?? '-',
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),

                                    /// HEADER TABLE
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
                                                'Name',
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

                                    Divider(),

                                    /// RATING
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(1),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: List.generate(
                                        data?.ratings.length ?? 0,
                                        (subIndex) {
                                          final ratings =
                                              data?.ratings[subIndex];
                                          return TableRow(
                                            children: [
                                              /// CRITERIA
                                              TableCell(
                                                child: Text(
                                                  ratings?.criteria?.name ??
                                                      '-',
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

                                              /// RATING VALUE
                                              TableCell(
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: Container(
                                                    height: 35,
                                                    width: double.infinity,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          vertical: 5,
                                                        ),
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                        },
                                      ),
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
                  : const SizedBox(),

              /// BUTTON CALCULATE RESULT
              _sawMatrix != null && _sawMatrix!.isNotEmpty
                  ? ElevatedButton(
                    onPressed: () async {
                      _sawResult = await _saw
                          .calculateSawResult(matrix: _sawMatrix!)
                          .catchError((e) {
                            if (context.mounted) {
                              _helper.showScaffoldMessenger(
                                context: context,
                                message: e.toString(),
                              );
                            }

                            return <SawResult>[];
                          });

                      Future.delayed(Duration(milliseconds: 300), () {
                        setState(() {});
                      });
                    },
                    child: Text(
                      'Calculate SAW Result',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
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
              showSawCriteriaInputDialog(
                context,
                onSave: (value) {
                  setState(() {
                    _listSawCriteria.add(value);
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
            showSawCriteriaInputDialog(
              context,
              onSave: (value) {
                setState(() {
                  _listSawCriteria.add(value);
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
}
