import 'package:example/ahp/show_ahp_pairwise_comparison_scale_dialog.dart';
import 'package:example/example_input_widget.dart';
import 'package:example/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decision_making/feature/ahp/presentation/ahp.dart';

class AhpExamplePage extends StatefulWidget {
  const AhpExamplePage({super.key});

  @override
  State<AhpExamplePage> createState() => _AhpExamplePageState();
}

class _AhpExamplePageState extends State<AhpExamplePage> {
  final _criteriaController = TextEditingController();
  final _alternativeController = TextEditingController();
  late TextStyle _textStyle;
  late AHP _ahp;
  late List<AhpHierarchy> _listHierarchy;
  late List<AhpItem> _listCriteria;
  late List<AhpItem> _listAlternative;
  late List<PairwiseComparisonInput> _inputCriteria;
  late List<PairwiseAlternativeInput> _inputAlternative;
  late Helper _helper;
  AhpResult? _ahpResult;

  @override
  void initState() {
    super.initState();
    _ahp = AHP();
    _textStyle = TextStyle(fontSize: 18);
    _listHierarchy = [];
    _listAlternative = [];
    _listCriteria = [];
    _inputCriteria = [];
    _inputAlternative = [];
    _helper = Helper();
  }

  @override
  void dispose() {
    super.dispose();
    _criteriaController.dispose();
    _alternativeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Analytical Hierarchy Process'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(
            children: [
              /// CRITERIA YOU WANT
              ExampleInputWidget(
                title: 'Criteria',
                controller: _criteriaController,
                onPressed:
                    () => _addItem(
                      _criteriaController,
                      _listCriteria,
                      (name) => AhpItem(name: name),
                    ),
              ),

              /// LIST CRITERIA
              _listCriteria.isNotEmpty
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
                        itemCount: _listCriteria.length,
                        itemBuilder: (context, index) {
                          var data = _listCriteria[index];
                          return Text(
                            '${index + 1}. ${data.name}',
                            style: _textStyle,
                          );
                        },
                      ),
                    ),
                  )
                  : SizedBox(height: 10),

              const Divider(),

              /// ALTERNATIVE YOU HAVE
              ExampleInputWidget(
                title: 'Alternative',
                controller: _alternativeController,
                onPressed:
                    () => _addItem(
                      _alternativeController,
                      _listAlternative,
                      (name) => AhpItem(name: name),
                    ),
              ),

              /// LIST ALTERNATIVE
              _listAlternative.isNotEmpty
                  ? Container(
                    constraints: BoxConstraints(maxHeight: 100),
                    margin: EdgeInsets.only(bottom: 20, top: 10),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    width: double.infinity,
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: _listAlternative.length,
                        itemBuilder: (context, index) {
                          var data = _listAlternative[index];
                          return Text(
                            '${index + 1}. ${data.name}',
                            style: _textStyle,
                          );
                        },
                      ),
                    ),
                  )
                  : SizedBox(height: 20),

              /// GENERATE HIERARCHY STRUCTURE & PAIRWISE MATRIX TEMPLATE
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    /// GENERATE HIERARCHY FIRST BEFORE GENERATE CRITERIA INPUTS OR ALTERNATIVE INPUTS
                    _listHierarchy = await _ahp
                        .generateHierarchy(
                          listCriteria: _listCriteria,
                          listAlternative: _listAlternative,
                        )
                        .catchError((e) {
                          if (context.mounted) {
                            _helper.showScaffoldMessenger(
                              context: context,
                              message: e.toString(),
                            );
                          }

                          return <AhpHierarchy>[];
                        })
                        .whenComplete(() {});

                    /// GENERATE CRITERIA INPUTS
                    _inputCriteria = await _ahp.generateCriteriaInputs();

                    /// GENERATE ALTERNATIVE INPUTS
                    _inputAlternative = await _ahp.generateAlternativeInputs(
                      hierarchyNodes: _listHierarchy,
                    );

                    Future.delayed(Duration(milliseconds: 300), () {
                      setState(() {});
                    });
                  },
                  child: Text(
                    'Generate Hierarchy Structure and Pairwise Matrix Template',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              /// PAIRWISE CRITERIA INPUTS
              _inputCriteria.isNotEmpty
                  ? Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pairwise Criteria',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        /// CRITERIA ITEMS
                        Container(
                          color: Colors.grey.shade300,
                          height: 200,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(),
                                  },
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: List.generate(_inputCriteria.length, (
                                    index,
                                  ) {
                                    final criteria = _inputCriteria[index];
                                    return TableRow(
                                      children: [
                                        /// LEFT CRITERIA
                                        TableCell(
                                          child: Text(
                                            criteria.left.name,
                                            style: _textStyle,
                                          ),
                                        ),

                                        /// INPUTTER
                                        TableCell(
                                          child: InkWell(
                                            onTap: () {
                                              /// SHOW COMPARISON SCALE DIALOG
                                              showAhpPairwiseComparisonScaleDialog(
                                                context,
                                                comparison:
                                                    _ahp.listAhpPairwiseComparisonScale,
                                                leftItemName:
                                                    criteria.left.name,
                                                rightItemName:
                                                    criteria.right.name,
                                                onSelected: (scale, important) {
                                                  if (scale != null &&
                                                      important != null) {
                                                    /// UPDATE CRITERIA VALUE
                                                    _inputCriteria = _ahp
                                                        .updateCriteriaInputs(
                                                          _inputCriteria,
                                                          id: criteria.id,
                                                          scale: scale.value,
                                                          isLeftMoreImportant:
                                                              important,
                                                        );

                                                    setState(() {});
                                                  }
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 60,
                                              width: double.infinity,
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              child: Text(
                                                criteria.preferenceValue != null
                                                    ? '${criteria.preferenceValue} - ${criteria.isLeftMoreImportant == true ? 'left item is more important' : 'right item is more important'}'
                                                    : 'scale comparison',
                                                style: _textStyle,
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// RIGHT CRITERIA
                                        TableCell(
                                          child: Text(
                                            criteria.right.name,
                                            style: _textStyle,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox(),

              /// PAIRWISE ALTERNATIVE INPUTS
              _inputAlternative.isNotEmpty
                  ? Container(
                    margin: EdgeInsets.only(top: 20),
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
                          'Pairwise Alternative',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        /// ALTERNATIVE ITEMS
                        Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: _inputAlternative.length,
                              padding: EdgeInsets.only(right: 10),
                              itemBuilder: (context, index) {
                                final data = _inputAlternative[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// ALTERNATIVE PER CRITERIA
                                    Text(
                                      data.criteria.name,
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    /// ALTERNATIVE
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(),
                                        1: FlexColumnWidth(3),
                                        2: FlexColumnWidth(),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: List.generate(data.alternative.length, (
                                        subIndex,
                                      ) {
                                        final alt = data.alternative[subIndex];
                                        return TableRow(
                                          children: [
                                            /// LEFT
                                            TableCell(
                                              child: Text(
                                                alt.left.name,
                                                style: _textStyle,
                                              ),
                                            ),

                                            /// COMPARISON ALTERNATIVE
                                            TableCell(
                                              child: InkWell(
                                                onTap: () {
                                                  /// SHOW COMPARISON SCALE DIALOG
                                                  showAhpPairwiseComparisonScaleDialog(
                                                    context,
                                                    comparison:
                                                        _ahp.listAhpPairwiseComparisonScale,
                                                    leftItemName: alt.left.name,
                                                    rightItemName:
                                                        alt.right.name,
                                                    onSelected: (
                                                      scale,
                                                      important,
                                                    ) {
                                                      if (scale != null &&
                                                          important != null) {
                                                        /// UPDATE ALTERNATIVE VALUE
                                                        _inputAlternative = _ahp
                                                            .updateAlternativeInputs(
                                                              _inputAlternative,
                                                              criteriaId:
                                                                  data
                                                                      .criteria
                                                                      .id,
                                                              alternativeId:
                                                                  alt.id,
                                                              scale:
                                                                  scale.value,
                                                              isLeftMoreImportant:
                                                                  important,
                                                            );

                                                        setState(() {});
                                                      }
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: double.infinity,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                  ),
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    alt.preferenceValue != null
                                                        ? '${alt.preferenceValue} - ${alt.isLeftMoreImportant == true ? 'left item is more important' : 'right item is more important'}'
                                                        : 'scale comparison',
                                                    style: _textStyle,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            /// RIGHT
                                            TableCell(
                                              child: Text(
                                                alt.right.name,
                                                style: _textStyle,
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
                  : const SizedBox(),

              /// GENERATE PAIRWISE MATRIX
              _inputAlternative.isNotEmpty && _inputCriteria.isNotEmpty
                  ? Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          /// GET RESULT AHP
                          _ahpResult = await _ahp
                              .getAhpResult(
                                hierarchy: _listHierarchy,
                                inputsCriteria: _inputCriteria,
                                inputsAlternative: _inputAlternative,
                              )
                              .catchError((e) {
                                if (context.mounted) {
                                  /// SHOW MESSAGE IF CATCH EXCEPTION
                                  _helper.showScaffoldMessenger(
                                    context: context,
                                    message: e.toString(),
                                  );
                                }

                                return AhpResult();
                              });

                          Future.delayed(Duration(milliseconds: 300), () {
                            setState(() {});
                          });
                        },
                        child: Text(
                          'Generate Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                  : const SizedBox(),

              /// RESULT
              _ahpResult != null
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),

                      Text(
                        'Result',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      /// RESULT ITEMS
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(top: 10),
                        itemCount: _ahpResult?.results?.length ?? 0,
                        itemBuilder: (context, index) {
                          var data = _ahpResult?.results?[index];
                          return Text(
                            '${data?.name}: ${data?.value}',
                            style: _textStyle,
                          );
                        },
                      ),

                      const Divider(),

                      /// RESULT CONSISTENCY CRITERIA RATIO
                      Text(
                        'criteria consistency ratio: ${_ahpResult?.consistencyCriteriaRatio}',
                        style: _textStyle,
                      ),

                      const Divider(),

                      /// IS VALID CRITERIA?
                      Text(
                        'is criteria consistent: ${_ahpResult?.isConsistentCriteria}',
                        style: _textStyle,
                      ),

                      const Divider(),

                      /// RESULT ALTERNATIVE RATIO
                      Text(
                        'alternative consistency ratio: ${_ahpResult?.consistencyAlternativeRatio}',
                        style: _textStyle,
                      ),

                      const Divider(),

                      /// IS VALID ALTERNATIVE?
                      Text(
                        'is alternative consistent: ${_ahpResult?.isConsistentAlternative}',
                        style: _textStyle,
                      ),

                      const Divider(),

                      /// NOTE WILL BE DISPLAYED IF THE CRITERIA OR ALTERNATIVES ARE INVALID
                      _ahpResult?.note != null
                          ? Text(_ahpResult!.note!, style: _textStyle)
                          : const SizedBox(),
                    ],
                  )
                  : const SizedBox(),

              SizedBox(height: paddingBottom),
            ],
          ),
        ),
      ),
    );
  }

  /// ADD ITEM TO CRITERIA OR ALTERNATIVE
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
