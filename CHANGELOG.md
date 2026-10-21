## Unreleased

### Proposed Version: 1.3.0

### Breaking Changes / Behavior Changes
- **Isolate execution is now opt-in (`useIsolate: false` by default):** Automatic threshold offloading to background isolate (>80 alternatives / >25 criteria) has been removed from SAW, TOPSIS, and AHP based on empirical benchmark findings showing main thread execution is 6x-70x faster for datasets up to 2000x50.
- All calculation methods (`getSawResult`, `getResultWithExistingMatrix`, `getTopsisResult`, `getTopsisResultWithExistingMatrix`, `getAhpResult`, and matrix generators) now accept optional `bool useIsolate = false`.
- When `useIsolate: false`, `DecisionIsolateMain` and `WidgetsBindingObserver` are not initialized, preventing unnecessary worker spawns and idle timers.
- **Penghapusan export internal isolate dari barrel (`lib/flutter_decision_making.dart`):** `DecisionIsolateMain`, `decision_isolate_message.dart`, dan `decision_isolate_worker.dart` tidak lagi di-export melalui barrel utama karena merupakan detail implementasi internal.
  - *Panduan Migrasi:* Pengguna normal tidak perlu mengakses isolate secara manual dan cukup meneruskan parameter `useIsolate: true` pada API publik (`getSawResult`, `getTopsisResult`, `getAhpResult`). Jika pengujian atau kode khusus memerlukan akses ke instance isolate manager, import file secara langsung:
    `import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';`

### Added
- **Pemisahan package `decision_making_core` (Pure Dart):** Dibuat package mandiri `packages/decision_making_core` tanpa dependensi Flutter (`dart test` dan `dart analyze` bersih, SDK `>=3.0.0 <4.0.0`). Mendukung eksekusi sinkron (`SawCalculator.calculate`, `TopsisCalculator.calculate`, `AhpCalculator.calculate`).
- Export entity `decision_making_core` di barrel utama `package:flutter_decision_making/flutter_decision_making.dart` secara selektif (`show`) untuk interoperabilitas penuh tipe entitas tanpa mengekspos engine kalkulator mentah.
- Export `TOPSIS` di barrel utama (`lib/flutter_decision_making.dart`): class `TOPSIS`, `TopsisRawMatrix`, dan tipe terkait kini dapat diimpor langsung dari `package:flutter_decision_making/flutter_decision_making.dart`.

### Urutan Rilis / Publishing Workflow
1. **Rilis Core Terlebih Dahulu:** Masuk ke direktori `packages/decision_making_core` dan terbitkan package ke pub.dev (`dart pub publish`). Versi awal adalah `0.1.0`.
2. **Hapus Overrides di Root & Subproject:** Setelah `decision_making_core` terbit dan terindeks di pub.dev, hapus blok `dependency_overrides` pada `pubspec.yaml`, `example/pubspec.yaml`, dan `benchmark/pubspec.yaml`.
3. **Rilis Root Package:** Jalankan `flutter test` dan `flutter pub publish` untuk merilis `flutter_decision_making` (diusulkan versi `1.3.0`).

### Fixed
- Ranking TOPSIS salah di versi 1.2.0 untuk data > 80 alternatif atau > 25 kriteria karena worker memanggil normalisasi SAW (`normalizeWeightedMatrixIsolate`) alih-alih normalisasi Euclidean (`normalizeEuclideanMatrixIsolate`) pada `TopsisProcessingIsolateCommand.normalizeEuclidean`.
- Hapus command mati `TopsisProcessingIsolateCommand.normalizeMatrix` dari enum dan worker isolate.

### Open Items / Planned
- Serialisasi isolate memakai Map/DTO dan menjadi bottleneck; pertimbangkan data datar (`Float64List` / `TransferableTypedData`) di Fase 3.
- Putuskan semantik rank saat seri (rank sama vs rank unik sekuensial) dan tiebreak eksplisit (perilaku saat ini: rank unik sekuensial mengikuti urutan input pada data kecil karena `List.sort` Dart tidak dijamin stabil pada data besar).

---

## 1.2.0

### Updated
* make shared function to generate matrix for SAW and TOPSIS
* added algorithm TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)

---

## 1.1.2

### Updated
* add support me on ko-fi, saweria to readme

---

## 1.1.1

### Updated
* adding Simple Additive Weighting (SAW) algorithm
* main isolate manager, make to multi-command isolate
* minimum flutter version
* minor update AHP

---

## 1.0.6

### Updated
* update README.md
* Refactored AHP feature for improved maintainability and performance
* On mobile and desktop platforms, replaced compute with Isolate.spawn for heavy processing tasks:
    - `generateResultPairwiseMatrixCriteria`
    - `generateResultPairwiseMatrixAlternative`
    - `calculateEigenVectorCriteria`
    - `calculateEigenVectorAlternative`
    - `checkConsistencyRatio`
    - `ahpFinalScore`

---

## 1.0.5

### Changed
- Refactor feature AHP.

### Added
- Added isolate-based heavy processing for:
    - `generatePairwiseAlternativeInput`
    - `generateResultPairwiseMatrixCriteria`
    - `generateResultPairwiseMatrixAlternative`
    - `calculateEigenVectorCriteria`
    - `calculateEigenVectorAlternative`
    - `checkConsistencyRatio`

---

## 1.0.4

* updated README with development note about upcoming support for SAW, TOPSIS, and other algorithms.
* Improved package description in pubspec.yaml to reflect ongoing development and future feature additions.

---

## 1.0.3

* update preference value: only return integer
* update README.md
* feature to reset all internal data and results to initial state

---

## 1.0.2

update docs

---

## 1.0.1

chore:
* Provide documentation
* Pass static analysis
* update README.md

---

## 1.0.0

* Flutter Decision Making with AHP algorithm initial release.