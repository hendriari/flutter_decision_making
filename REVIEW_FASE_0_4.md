# Review pekerjaan fase 0–4: `flutter_decision_making`

**Kesimpulan:** pekerjaan sudah menghasilkan banyak fondasi yang tepat, tetapi belum memenuhi seluruh kriteria fase 0–4. Saya belum menyarankan menyatakan fase 0, 3, atau 4 selesai sebelum gap di bawah dibereskan. Fase 1 sebagian besar terlihat tercakup; fase 2 memiliki data benchmark namun ukuran yang diminta tidak semuanya diukur.

## Ringkasan per fase

| Fase | Penilaian | Temuan |
|---|---|---|
| 0 — test gagal | Belum terverifikasi | Flutter test tidak dapat dijalankan di lingkungan review: Flutter mencoba menulis cache di `/opt/homebrew/share/flutter/...` dan mendapat `Operation not permitted`. Analisis Dart berhasil; hasil test core juga tidak dapat diperoleh karena SDK gagal menulis file telemetry di `~/.dart-tool`. Karena eksekusi terhenti sebelum test berjalan, ini kendala lingkungan, bukan bukti test gagal atau hijau. |
| 1 — golden test | Hampir sesuai | Ada tiga kasus per algoritma dan label `cross-checked`, plus edge case cost, nilai sama, serta AHP CR > 0.1. Nilai dan sumber perhitungan didokumentasikan di `packages/decision_making_core/test/golden/README.md`. Belum dapat mengonfirmasi seluruh test lolos di lingkungan ini. |
| 2 — benchmark isolate | Sebagian | Tersedia skrip dan tabel hasil. Namun SAW/TOPSIS mengukur 10×5, 80×25, 200×25, 500×25, 2000×50; task mensyaratkan 10×5, 80×25, 500×25, 2000×50. Ukuran tambahan tidak masalah, tetapi bukti 80×25 dll. ada. Fase ini belum menambahkan ambang otomatis; API `useIsolate` default `false` tercermin di changelog. Angka 2000×50 menunjukkan isolate jauh lebih lambat end-to-end, sehingga keputusan opt-in masuk akal. |
| 3 — pisahkan core | Belum selesai | Package core terpisah, berisi AHP/SAW/TOPSIS sinkron, dan sumbernya tidak tampak mengimpor Flutter. Tetapi implementasi API kalkulasi lama root belum didelegasikan ke core; perubahan yang terlihat hanya memakai core untuk method hasil terperinci SAW/TOPSIS. Ini bertentangan dengan tujuan wrapper tipis dan klaim changelog bahwa wrapper mendelegasikan kalkulasi. Perlu verifikasi/update porting semua jalur AHP/SAW/TOPSIS. |
| 4 — hasil terjelaskan | Belum selesai | SAW dan TOPSIS memiliki result detail, `toJson()`, serta golden assertion nilai perantara. AHP belum: `AhpResult`/`AhpResultDetail` tidak membawa matriks perbandingan, normalisasi, eigenvector, λmax/CI/CR sebagai detail hasil kalkulasi, dan `toJson()` hasil belum tersedia. Kriteria fase ini meminta seluruh objek hasil, termasuk AHP. |

## Temuan penting

1. **AHP belum mendapat detail hasil fase 4.** Core `AhpCalculator` menghitung matriks, bobot, dan konsistensi di dalam pipeline, tetapi hasil akhirnya hanya `AhpResult` dengan ranking/flag/ringkasan CR. Buat objek detail atau perluas hasil dengan field tambahan tanpa menghapus field lama; sertakan `toJson()`.
2. **Delegasi core belum menyeluruh.** `SAW.getSawDetailedResult` dan `TOPSIS.getTopsisDetailedResult` memanggil calculator core. Jalur API lama tetap lewat datasource legacy Flutter. Perlu audit pula jalur AHP. Setelah refaktor, pengujian parity perlu membuktikan API lama dan core memberikan keluaran yang sama.
3. **Benchmark belum membuktikan angka untuk semua kondisi yang dijanjikan secara konsisten.** Hasil dokumentasi berisi kondisi profile dan 10 pengulangan, tetapi skrip mengukur juga metrik `mainThreadBlocked` serta isolate call pertama/warm. Jelaskan bahwa perbandingan ini menghitung overhead isolate (serialisasi, komunikasi, lifecycle) dan bukan hanya waktu algoritma. Jangan menganggap hasil Apple Silicon sebagai ambang universal lintas platform.
4. **Periksa pengumuman breaking change dan versi.** `pubspec.yaml` berubah dari 1.2.0 ke 1.3.0 sementara changelog sendiri menandai perubahan isolate default dan barrel export sebagai breaking. Ini perlu keputusan versi mayor atau penjelasan bahwa API yang dihapus bukan API publik yang dijamin. Jangan publish sebelum core lebih dulu tersedia di pub.dev; path override saat ini memang lokal.
5. **Klaim changelog lebih luas daripada bukti implementasi.** Changelog menyebut kalkulasi package Flutter telah mendelegasikan ke core, tetapi diff yang ditinjau belum menunjukkan itu untuk jalur API standar. Sesuaikan klaim setelah implementasi, bukan sebelum.

## Pemeriksaan yang dapat dilakukan

- `dart analyze` di root: **lulus, No issues found**.
- `dart analyze` di `packages/decision_making_core`: **lulus, No issues found**.
- `flutter test`: **tidak berjalan** karena SDK Flutter gagal memperbarui cache di `/opt/homebrew/share/flutter/bin/cache` (`Operation not permitted`).
- `dart test` core: **tidak berjalan**; proses Dart gagal menulis telemetry ke `/Users/hendriari/.dart-tool/dart-flutter-telemetry-session.json` sebelum menjalankan test.
- Pemindaian sumber core: tidak ditemukan import `package:flutter`, `dart:ui`, atau `WidgetsBinding` di `packages/decision_making_core/lib`.

## Rekomendasi urutan penuntasan

1. Ulangi `flutter test` dan `dart test` di host yang SDK/cache-nya bisa ditulis, simpan hasil aktual.
2. Pastikan kalkulasi standar di Flutter wrapper mendelegasikan ke core; pertahankan API lama dan tambah test parity.
3. Lengkapi AHP detailed result, serialisasi JSON, dan golden check nilai perantaranya.
4. Sesuaikan tabel benchmark pada task (atau dokumentasikan bahwa data tambahan memang sengaja diambil) dan rumuskan batas penggunaan isolate berdasarkan target platform.
5. Tinjau kembali versi rilis dan konsistensi changelog setelah perubahan implementasi final.

**Batas review:** ini adalah review statis atas working tree yang tersedia dan hasil perintah yang berhasil dimulai; test suite belum tervalidasi karena kendala izin filesystem SDK/telemetry di host.
