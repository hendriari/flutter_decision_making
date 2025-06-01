import 'package:example/helper.dart';
import 'package:example/show_pairwise_comparison_scale_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
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

      home: const MyHomePage(title: 'Flutter Decision Making Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _criteriaController = TextEditingController();
  final _alternativeController = TextEditingController();
  late TextStyle _textStyle;
  late FlutterDecisionMaking _decisionMaking;
  late List<Criteria> _listCriteria;
  late List<Alternative> _listAlternative;
  late List<PairwiseComparisonInput> _inputCriteria;
  late List<PairwiseAlternativeInput> _inputAlternative;
  late Helper _helper;

  @override
  void initState() {
    super.initState();
    _decisionMaking = FlutterDecisionMaking();
    _textStyle = TextStyle(fontSize: 18);
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
            bottom: paddingBottom + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// CRITERIA YOU WANT
              _buildInputWidget(
                title: 'Criteria',
                controller: _criteriaController,
                onPressed:
                    () => _addItem(
                      _criteriaController,
                      _listCriteria,
                      (name) => Criteria(name: name),
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
                        shrinkWrap: true,
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
                      (name) => Alternative(name: name),
                    ),
              ),

              /// LIST ALTERNATIVE
              _listAlternative.isNotEmpty
                  ? Container(
                    constraints: BoxConstraints(maxHeight: 100),
                    margin: EdgeInsets.only(bottom: 40, top: 10),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    width: double.infinity,
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
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
                  : SizedBox(height: 40),

              /// GENERATE HIERARCHY STRUCTURE & PAIRWISE MATRIX TEMPLATE
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _decisionMaking
                        .generateHierarchyAndPairwiseTemplate(
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
                        });

                    setState(() {
                      /// COPY RESULT TO LIST
                      _inputCriteria =
                          _decisionMaking.listPairwiseCriteriaInput;
                      _inputAlternative =
                          _decisionMaking.listPairwiseAlternativeInput;
                    });
                  },
                  child: Text(
                    'Generate Hierarchy Structure and Pairwise Matrix Template',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              /// PAIRWISE CRITERIA
              _inputCriteria.isNotEmpty
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),

                      Text(
                        'Pairwise Criteria',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      ListView.builder(
                        itemCount: _inputCriteria.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var criteria = _inputCriteria[index];
                          return Row(
                            children: [
                              Text(criteria.left.name, style: _textStyle),

                              /// SELECT VALUE COMPARISON
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showPairwiseComparisonScaleDialog(
                                      context,
                                      comparison:
                                          _decisionMaking
                                              .listPairwiseComparisonScale,
                                      onSelected: (value) {
                                        if (value != null) {
                                          _decisionMaking
                                              .updatePairwiseCriteriaValue(
                                                id: criteria.id,
                                                value: value,
                                              );

                                          setState(() {
                                            _inputCriteria =
                                                _decisionMaking
                                                    .listPairwiseCriteriaInput;
                                          });
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
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Text(
                                      criteria.preferenceValue != null
                                          ? '${criteria.preferenceValue?.value} - ${criteria.preferenceValue?.description}'
                                          : 'scale comparison',
                                      style: _textStyle,
                                    ),
                                  ),
                                ),
                              ),

                              Text(criteria.right.name, style: _textStyle),
                            ],
                          );
                        },
                      ),
                    ],
                  )
                  : const SizedBox(),

              /// PAIRWISE ALTERNATIVE
              _inputAlternative.isNotEmpty
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),

                      Text(
                        'Pairwise Alternative',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      ListView.builder(
                        itemCount: _inputAlternative.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
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
                                    Text(e.left.name, style: _textStyle),

                                    /// SELECT VALUE COMPARISON
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showPairwiseComparisonScaleDialog(
                                            context,
                                            comparison:
                                                _decisionMaking
                                                    .listPairwiseComparisonScale,
                                            onSelected: (value) {
                                              if (value != null) {
                                                _decisionMaking
                                                    .updatePairwiseAlternativeValue(
                                                      id: data.criteria.id,
                                                      alternativeId: e.id,
                                                      value: value,
                                                    );

                                                setState(() {
                                                  _inputAlternative =
                                                      _decisionMaking
                                                          .listPairwiseAlternativeInput;
                                                });
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
                                                ? '${e.preferenceValue?.value} - ${e.preferenceValue?.description}'
                                                : 'scale comparison',
                                            style: _textStyle,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Text(e.right.name, style: _textStyle),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  )
                  : const SizedBox(),

              /// GENERATE PAIRWISE MATRIX
              _decisionMaking.listPairwiseAlternativeInput.isNotEmpty &&
                      _decisionMaking.listPairwiseCriteriaInput.isNotEmpty
                  ? Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _decisionMaking.generateResult().catchError((
                            e,
                          ) {
                            if (context.mounted) {
                              _helper.showScaffoldMessenger(
                                context: context,
                                message: e.toString(),
                              );
                            }
                          });

                          setState(() {});
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
              _decisionMaking.ahpResult.isNotEmpty
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

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: _decisionMaking.ahpResult.length,
                        itemBuilder: (context, index) {
                          var data = _decisionMaking.ahpResult[index];
                          return Text(
                            '${data.name}: ${data.value}',
                            style: _textStyle,
                          );
                        },
                      ),
                    ],
                  )
                  : const SizedBox(),
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
