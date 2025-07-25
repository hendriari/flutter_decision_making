import 'package:example/helper.dart';
import 'package:example/show_pairwise_comparison_scale_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      home: const AHPPage(title: 'Flutter Decision Making Example'),
    );
  }
}

class AHPPage extends StatefulWidget {
  const AHPPage({super.key, required this.title});

  final String title;

  @override
  State<AHPPage> createState() => _AHPPageState();
}

class _AHPPageState extends State<AHPPage> {
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
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(
            children: [
              /// CRITERIA YOU WANT
              _buildInputWidget(
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
              _buildInputWidget(
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
                            child: ListView.builder(
                              itemCount: _inputCriteria.length,
                              padding: EdgeInsets.only(right: 10),
                              itemBuilder: (context, index) {
                                var criteria = _inputCriteria[index];
                                return Row(
                                  children: [
                                    /// NAME
                                    Text(criteria.left.name, style: _textStyle),

                                    /// SELECT VALUE COMPARISON
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          /// SHOW COMPARISON SCALE DIALOG
                                          showPairwiseComparisonScaleDialog(
                                            context,
                                            comparison:
                                                _ahp.listPairwiseComparisonScale,
                                            leftItemName: criteria.left.name,
                                            rightItemName: criteria.right.name,
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
                                          height: 40,
                                          width: double.infinity,
                                          alignment: Alignment.centerLeft,
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
                                            criteria.preferenceValue != null
                                                ? '${criteria.preferenceValue} - ${criteria.isLeftMoreImportant == true ? 'left item is more important' : 'right item is more important'}'
                                                : 'please select scale comparison',
                                            style: _textStyle,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// NAME
                                    Text(
                                      criteria.right.name,
                                      style: _textStyle,
                                    ),
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
                                    Text(
                                      data.criteria.name,
                                      style: _textStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    ...data.alternative.map(
                                      (e) => Row(
                                        children: [
                                          /// NAME
                                          Text(e.left.name, style: _textStyle),

                                          /// SELECT VALUE COMPARISON
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                /// SHOW COMPARISON SCALE DIALOG
                                                showPairwiseComparisonScaleDialog(
                                                  context,
                                                  comparison:
                                                      _ahp.listPairwiseComparisonScale,
                                                  leftItemName: e.left.name,
                                                  rightItemName: e.right.name,
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
                                                            alternativeId: e.id,
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
                                                height: 40,
                                                width: double.infinity,
                                                alignment: Alignment.centerLeft,
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
                                                  e.preferenceValue != null
                                                      ? '${e.preferenceValue} - ${e.isLeftMoreImportant == true ? 'left item is more important' : 'right item is more important'}'
                                                      : 'please select scale comparison',
                                                  style: _textStyle,
                                                ),
                                              ),
                                            ),
                                          ),

                                          /// NAME
                                          Text(e.right.name, style: _textStyle),
                                        ],
                                      ),
                                    ),
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

  /// INPUT FOR CRITERIA OR ALTERNATIVE
  Widget _buildInputWidget({
    required String title,
    required TextEditingController controller,
    required Function() onPressed,
  }) {
    return Row(
      children: [
        Text(title, style: _textStyle),

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
