[![pub version](https://img.shields.io/pub/v/flutter_decision_making.svg)](https://pub.dev/packages/flutter_decision_making)

## ✨ About

**Flutter package for practical Multi-Criteria Decision Making (MCDM). Providing algorithms such as AHP, SAW, and TOPSIS to help developers perform weighting, evaluation, and ranking of alternatives easily and accurately within their Flutter applications.**

| Status | Algorithm                                                               | Available in version |
|:-------|:------------------------------------------------------------------------|:---------------------|
| ✅      | AHP (Analytic Hierarchy Process)                                        | 1.0.0                |
| ✅     | SAW (Simple Additive Weighting)                                         | 1.1.0                |
| ✅     | TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) | 1.2.0                |

---

## 🎯 Typical Use Cases

Suitable for building decision support features such as:

- HR candidate or promotion selection
- Vendor or project evaluation
- Scholarship or student ranking
- Feature prioritization in product management
- Internal corporate decision-making systems
- Recommendation or comparison apps

---

## 📚 Usage Guide
You can use this package in two ways depending on your needs:

1. Using all algorithms together  
   Initialize the `FlutterDecisionMaking` class to access all available algorithms.

```dart
late FlutterDecisionMaking _decisionMaking;
AhpResult? _ahpResult;
List<WeightedDecisionResult>? _sawResult;
List<WeightedDecisionResult>? _topsisResult;

@override
void initState() {
  super.initState();
  _decisionMaking = FlutterDecisionMaking();
}

// Usage example:
// for AHP
_ahpResult = await _decisionMaking.ahp.getAhpResult(...);

// for SAW
_sawResult = await _decisionMaking.saw.getSawResult(...);

// for TOPSIS
_topsisResult = await _decisionMaking.topsis.getTopsisResult(...);
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

| Link                                                                                                    | Description                                                                                                                                                                                      |
|:--------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [AHP Doc](https://github.com/hendriari/flutter_decision_making/wiki/Analytic-Hierarchy-Process-(AHP))   | If you need a method that is able to determine weights accurately through pairwise comparisons, validate the consistency of assessments, and work well on subjective or multilevel criteria.     |
| [SAW Doc](https://github.com/hendriari/flutter_decision_making/wiki/Simple-Additive-Weighting-(SAW))    | If you need a simple, fast, easy to calculate, and easy to implement method for ranking alternatives based on criteria weights and values.                                                       |
| [TOPSIS Doc](https://github.com/hendriari/flutter_decision_making/wiki/TOPSIS-(Technique-for-Order-Preference-by-Similarity-to-Ideal-Solution)) | If you need a method that ranks alternatives based on their distance to the ideal best and ideal worst solutions, providing a more discriminative and robust decision-making result.                                                      |
---

## 📈 Performance Profiling

Major method logs:
- Start and end timestamps.
- Execution duration (in milliseconds).

> Useful for debugging and optimization during development.

---

## ⚡ Kapan Memakai Isolate (`useIsolate`)

Secara *default*, seluruh perhitungan berjalan di **main thread** (`useIsolate: false`). Isolate bersifat opsional (*opt-in*) melalui parameter `useIsolate: true`.

### Data Hasil Benchmark Riil (via Public API)
Hasil pengujian empiris pada **Apple Silicon macOS (M-series)** dalam mode `--profile` (AOT compiled, Impeller backend, 10 iterasi setelah 3x *warm-up*):

| Kasus & Ukuran Data (Alt × Crt) | Main Thread (ms)<br>median [min–max] | Isolate Warm (ms)<br>median [min–max] | Blokir Main Thread (ms)<br>median [min–max] |
| :--- | :--- | :--- | :--- |
| **SAW 80 × 25** | **0.19 ms** [0.18 – 0.35] | 4.35 ms [3.01 – 5.86] | 0.85 ms [0.00 – 3.03] |
| **SAW 2000 × 50** | **8.71 ms** [8.39 – 12.27] | 449.24 ms [411.99 – 477.15] | 244.23 ms [219.73 – 262.51] |
| **TOPSIS 80 × 25** | **0.52 ms** [0.50 – 0.55] | 4.02 ms [3.33 – 6.18] | 0.80 ms [0.00 – 3.34] |
| **TOPSIS 2000 × 50** | **47.53 ms** [40.32 – 52.14] | 526.39 ms [464.34 – 605.88] | 277.99 ms [223.17 – 306.31] |
| **AHP 80 × 10** | **31.71 ms** [31.21 – 52.50] | 51.01 ms [47.90 – 66.97] | 25.84 ms [23.09 – 39.94] |

> **Catatan Pengukuran "Blokir Main Thread":** Diukur menggunakan pemantauan lag event-loop (`LagTracker`) selama eksekusi `useIsolate: true`. Nilai `0.000 ms` pada dataset kecil (mis. 10×5) terjadi karena durasi blokir sinkron main thread berada di bawah batas resolusi timer/jitter event-loop (< 1 ms), sehingga tidak berpotensi menimbulkan jank/frame drop.

### Rekomendasi
- **Gunakan `useIsolate: false` (Default, Direkomendasikan):** Untuk hampir semua kasus MCDM di Flutter (< 2000 alternatif). Menghitung langsung di *main thread* selesai dalam < 9 ms untuk SAW, < 48 ms untuk TOPSIS, dan < 32 ms untuk AHP, tanpa overhead serialisasi antar isolate.
- **Kapan memakai `useIsolate: true`?** Jika Anda ingin mencegah komputasi matematika berjalan di UI thread pada dataset sangat besar di perangkat berdaya rendah, dengan konsekuensi total *execution time* lebih lama karena overhead serialisasi Map/DTO.

---

## 💡 Want Another Algorithm?

We are continuously improving this package 🚀

If you would like to see a new algorithm (e.g., WP, ELECTRE, MOORA, PROMETHEE, etc.) added:

👉 Please open a discussion:
[![GitHub Discussions](https://img.shields.io/badge/Join-Discussion-2ea44f?logo=github&logoColor=white)](https://github.com/hendriari/flutter_decision_making/discussions)

⚠️ Note:
New algorithms will be prioritized based on:
- Community interest
- Contribution support (PRs are welcome!)
- Maintainer availability

Contributions are highly appreciated 🙌

---
## 🎁 Support Me
[![Ko-Fi](https://badgen.net/badge/icon/ko-fi?icon=kofi&color=red&label)](https://ko-fi.com/hendriari) [![Saweria Badge](https://img.shields.io/badge/Saweria-Donate-orange?style=flat&logo=buymeacoffee&logoColor=white)](https://saweria.co/hendriarii)
 
---

## 🙋‍♂️ Contributing

We welcome all contributions and suggestions!

👉 Open an issue or submit a pull request at [GitHub Repo](https://github.com/hendriari/flutter_decision_making)
