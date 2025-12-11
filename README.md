[![pub version](https://img.shields.io/pub/v/flutter_decision_making.svg)](https://pub.dev/packages/flutter_decision_making) [![GitHub](https://badgen.net/badge/icon/ko-fi?icon=kofi&color=red&label)](https://ko-fi.com/hendriari) [![Saweria Badge](https://img.shields.io/badge/Saweria-Donate-orange?style=flat&logo=buymeacoffee&logoColor=white)](https://saweria.co/hendriarii)

## ✨ About

**Flutter package for practical multi-criteria decision-making, providing algorithms such as AHP, SAW, and TOPSIS (coming soon) to help developers perform weighting, evaluation, and ranking of alternatives easily and accurately within their Flutter applications.**

**Development Status:**

This package is currently under active development. We are committed to continuously enhancing the features and algorithms to support a broader range of decision-making methods. In upcoming versions, we plan to add several popular algorithms such as SAW, TOPSIS, and other methods to provide a richer selection of decision-making techniques.

| Status | Algorithm                                                               | Available in version |
|:-------|:------------------------------------------------------------------------|:---------------------|
| ✅      | AHP (Analytic Hierarchy Process)                                        | 1.0.0                |
| ✅     | SAW (Simple Additive Weighting)                                         | 1.1.0                |
| 🔜     | TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) | 1.2.0 (planned)      |

Thank you for your valuable feedback and continued support.

---

## 📚 Usage Guide
You can use this package in two ways depending on your needs:

1. Using all algorithms together  
   Initialize the `FlutterDecisionMaking` class to access all available algorithms (currently AHP and SAW).  
   More algorithms such as SAW and TOPSIS are planned for upcoming versions.

```dart
late FlutterDecisionMaking _decisionMaking;
AhpResult? _ahpResult;
List<SawResult>? _sawResult;

@override
void initState() {
  super.initState();
  _decisionMaking = FlutterDecisionMaking();
}

// Usage example:
// for AHP
_ahpResult = await _decisionMaking.ahp.getAhpResult(...);

// for SAW
_sawResult = await _decisionMaking.saw.calculateSawResult(...);
```

This is the easiest way if you want to use multiple algorithms in your project.

2. Using a specific algorithm only

If you only need a single algorithm (e.g., AHP), you can import and initialize it directly:

```dart
late AHP _ahp;
AhpResult? _ahpResult;

@override
void initState() {
  super.initState();
  _ahp = AHP();
}

// Usage example:
_ahpResult = await _ahp.getAhpResult(...);

```

---

## 📖 Algorithm Docs
For details on how to use the algorithm, you can visit the following documentation.

| Link                                                                                                  | Description                                                                                                                                                                                      |
|:------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [AHP Doc](https://github.com/hendriari/flutter_decision_making/wiki/Analytic-Hierarchy-Process-(AHP)) | If you need a method that is able to determine weights accurately through pairwise comparisons, validate the consistency of assessments, and work well on subjective or multilevel criteria.     |
| [SAW Doc](https://github.com/hendriari/flutter_decision_making/wiki/Simple-Additive-Weighting-(SAW))  | If you need a simple, fast, easy to calculate, and easy to implement method for ranking alternatives based on criteria weights and values.                                                       |
---

## 📈 Performance Profiling

Major method logs:
- Start and end timestamps.
- Execution duration (in milliseconds).

> Useful for debugging and optimization during development.

---
## Support Me
[![Ko-Fi](https://badgen.net/badge/icon/ko-fi?icon=kofi&color=red&label)](https://ko-fi.com/hendriari) [![Saweria Badge](https://img.shields.io/badge/Saweria-Donate-orange?style=flat&logo=buymeacoffee&logoColor=white)](https://saweria.co/hendriarii)
 
---

## 🙋‍♂️ Contributing

We welcome all contributions and suggestions!

👉 Open an issue or submit a pull request at [GitHub Repo](https://github.com/hendriari/flutter_decision_making)
