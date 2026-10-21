# Golden Tests Documentation

Dokumentasi ini mencatat spesifikasi input, hasil perhitungan, dan nilai ekspektasi untuk setiap kasus uji *golden test* pada package `flutter_decision_making`.

---

## Verifikasi

Angka expected dihitung dengan skrip Python murni, lalu diverifikasi ulang secara terpisah dengan NumPy (`np.linalg.eig` untuk AHP) pada tinjauan independen. Sumber data kasus di bawah ini bukan merupakan kutipan buku teks atau jurnal terbitan, melainkan kasus benchmark terverifikasi mandiri (*cross-checked*).

- **Label:** `cross-checked`
- **Toleransi komparasi numerik:** `1e-4` (`closeTo(expected, 1e-4)`).

> **Catatan Arsitektur (Fase 3b):**
> Sumber kebenaran angka expected numerik berada di package `decision_making_core` (`packages/decision_making_core/test/golden/`).
> Test golden di root (`test/golden/`) memverifikasi kesetaraan (parity) antara pembungkus root (`FlutterDecisionMaking`, `useIsolate: false` dan `useIsolate: true`) dengan hasil perhitungan core tanpa menduplikasi nilai expected hardcoded.

---

## Batasan AHP (Limitations)

1. **Metode Perhitungan Bobot:**
   Package ini mengimplementasikan metode aproksimasi **Normalized Column Averaging** (normalisasi jumlah kolom lalu rata-rata baris), bukan dekomposisi matriks eksak (*principal eigenvector*).
2. **Perbandingan dengan Eigenvector Eksak (`np.linalg.eig`):**
   - **Kasus 1:**
     - Bobot package (column averaging): `[0.647947, 0.229871, 0.122182]`, $\lambda_{max} = 3.003697$
     - Eigenvector eksak: `[0.648329, 0.229651, 0.122020]`, $\lambda_{max} = 3.003695$
     - Selisih bobot: $\approx 3.8 \times 10^{-4}$ (sangat kecil untuk matriks konsisten).
   - **Kasus 2:**
     - Bobot package (column averaging): `[0.557143, 0.320238, 0.122619]`, $\lambda_{max} = 3.018325$
     - Eigenvector eksak: `[0.558425, 0.319618, 0.121957]`, $\lambda_{max} = 3.018295$
     - Selisih bobot: $\approx 1.3 \times 10^{-3}$.
   - **Kesimpulan:** Untuk perbandingan matriks yang konsisten ($CR \le 0.1$), selisih aproksimasi terhadap eigenvector sebenarnya berada pada rentang $4 \times 10^{-4}$ hingga $1.3 \times 10^{-3}$. Namun untuk matriks yang tidak konsisten ($CR > 0.1$), selisihnya bisa menjadi lebih besar.
3. **Random Index (RI) & Ukuran Matriks:**
   - Tabel Random Index (RI) pada package memakai tabel Saaty untuk $n = 1..15$.
   - Untuk $n > 15$, dipakai fallback tetap `1.59` (`riTable[n] ?? 1.59`).
   - Estimasi RI hasil simulasi Monte Carlo (matriks resiprokal acak, skala 1/9..9):
     - $n = 16 \approx 1.59$
     - $n = 20 \approx 1.62$
     - $n = 30 \approx 1.67$
     - $n = 50 \approx 1.71$
     - $n = 80 \approx 1.73$
   - Akibatnya, nilai Consistency Ratio ($CR = CI / RI$) untuk $n > 15$ menjadi sedikit lebih konservatif (lebih besar) daripada seharusnya.
   - Selain itu, perbandingan berpasangan AHP dengan banyak elemen ($n > 15$) secara praktis tidak realistis bagi penilai manusia ($n(n-1)/2$ perbandingan; misal $n=80$ memerlukan 3.160 pertanyaan perbandingan).

---

## 1. Simple Additive Weighting (SAW)

### Kasus 1: Mixed benefit and cost 3x4 case
- **Label:** `cross-checked`
- **Deskripsi:** Pemilihan alternatif dengan 4 kriteria campuran (*benefit* dan *cost*).
- **Kriteria:**
  - $C_1$: Biaya / Investasi awal (Cost, Bobot = 25%, Nilai Max = 250)
  - $C_2$: Pangsa Pasar (Benefit, Bobot = 25%, Nilai Max = 5)
  - $C_3$: Kapasitas (Benefit, Bobot = 25%, Nilai Max = 5000)
  - $C_4$: Tingkat Risiko (Cost, Bobot = 25%, Nilai Max = 5)
- **Matriks Keputusan ($X$):**
  - $A_1$: `[100, 3, 3500, 1.5]`
  - $A_2$: `[150, 2, 4500, 2.0]`
  - $A_3$: `[200, 3, 3000, 3.5]`
- **Matriks Ternormalisasi ($R$):**
  - $A_1$: `[1.000000, 1.000000, 0.777778, 1.000000]`
  - $A_2$: `[0.666667, 0.666667, 1.000000, 0.750000]`
  - $A_3$: `[0.500000, 1.000000, 0.666667, 0.428571]`
- **Skor Akhir & Peringkat:**
  - $A_1$: Skor = `0.944444`, Peringkat = 1
  - $A_2$: Skor = `0.770833`, Peringkat = 2
  - $A_3$: Skor = `0.648810`, Peringkat = 3

### Kasus 2: Employee Performance Evaluation (All Benefit)
- **Label:** `cross-checked`
- **Kriteria:**
  - $C_1$: Technical Skill (Benefit, Bobot = 40%, Nilai Max = 100)
  - $C_2$: Communication (Benefit, Bobot = 30%, Nilai Max = 100)
  - $C_3$: Attitude (Benefit, Bobot = 30%, Nilai Max = 100)
- **Matriks Keputusan ($X$):**
  - $A_1$: `[80, 70, 90]`
  - $A_2$: `[90, 80, 70]`
  - $A_3$: `[75, 90, 85]`
  - $A_4$: `[85, 60, 80]`
- **Skor Akhir & Peringkat:**
  - $A_3$: Skor = `0.916667`, Peringkat = 1
  - $A_2$: Skor = `0.900000`, Peringkat = 2
  - $A_1$: Skor = `0.888889`, Peringkat = 3
  - $A_4$: Skor = `0.844444`, Peringkat = 4

### Kasus 3 (Edge Case): Kriteria Cost + Dua Alternatif Bernilai Sama (Tie)
- **Label:** `cross-checked`
- **Deskripsi:** Kasus tepi validasi kriteria *cost* dan perilaku deterministik saat skor seri.
- **Kriteria:**
  - $C_1$: Harga (Cost, Bobot = 50%, Nilai Max = 100)
  - $C_2$: Kualitas (Benefit, Bobot = 50%, Nilai Max = 100)
- **Matriks Keputusan ($X$):**
  - $A_1$: `[40, 80]`
  - $A_2$: `[40, 80]` (identik dengan $A_1$)
  - $A_3$: `[60, 60]`
- **Skor Akhir & Perilaku Peringkat:**
  - $A_1$: Skor = `1.000000`, Peringkat = 1
  - $A_2$: Skor = `1.000000`, Peringkat = 2
  - $A_3$: Skor = `0.708333`, Peringkat = 3
  - *Catatan Kasus Tie:*
    - Perilaku saat ini: rank unik sekuensial (1, 2, 3, ...), urutan alternatif seri mengikuti urutan input pada ukuran data kecil.
    - Catatan: `List.sort` Dart tidak dijamin stabil, sehingga urutan alternatif seri pada data besar tidak dijamin.
    - Item terbuka: putuskan semantik rank saat seri (rank sama vs rank unik) dan tiebreak eksplisit.

---

## 2. TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)

### Kasus 1: Consistent 4x4 case
- **Label:** `cross-checked`
- **Deskripsi:** 4 alternatif dan 4 kriteria dengan normalisasi Euclidean.
- **Kriteria:**
  - $C_1$: Benefit, Bobot = 30%, Nilai Max = 10
  - $C_2$: Benefit, Bobot = 20%, Nilai Max = 10
  - $C_3$: Benefit, Bobot = 25%, Nilai Max = 10
  - $C_4$: Cost, Bobot = 25%, Nilai Max = 10
- **Matriks Keputusan ($X$):**
  - $A_1$: `[5, 8, 4, 7]`
  - $A_2$: `[7, 6, 8, 9]`
  - $A_3$: `[8, 9, 6, 6]`
  - $A_4$: `[7, 7, 7, 7]`
- **Jarak Solusi Ideal & Skor Relatif:**
  - $A_1$: $D^+ = 0.104196$, $D^- = 0.043110$, Skor = `0.292655`, Peringkat = 4
  - $A_2$: $D^+ = 0.068285$, $D^- = 0.089363$, Skor = `0.566853`, Peringkat = 3
  - $A_3$: $D^+ = 0.038925$, $D^- = 0.100141$, Skor = `0.720097`, Peringkat = 1
  - $A_4$: $D^+ = 0.042970$, $D^- = 0.081676$, Skor = `0.655263`, Peringkat = 2

### Kasus 2: Vendor / Supplier Selection (Multiple Cost Criteria)
- **Label:** `cross-checked`
- **Kriteria:**
  - $C_1$: Kualitas Produk (Benefit, Bobot = 50%, Nilai Max = 100)
  - $C_2$: Penawaran Harga (Cost, Bobot = 30%, Nilai Max = 100)
  - $C_3$: Waktu Pengiriman (Cost, Bobot = 20%, Nilai Max = 100)
- **Matriks Keputusan ($X$):**
  - $S_1$: `[80, 20, 10]`
  - $S_2$: `[90, 30, 15]`
  - $S_3$: `[70, 15, 8]`
- **Skor Akhir & Peringkat:**
  - $S_3$: $D^+ = 0.071796$, $D^- = 0.135341$, Skor = `0.653390`, Peringkat = 1
  - $S_1$: $D^+ = 0.056351$, $D^- = 0.098798$, Skor = `0.636796`, Peringkat = 2
  - $S_2$: $D^+ = 0.135341$, $D^- = 0.071796$, Skor = `0.346610`, Peringkat = 3

### Kasus 3 (Edge Case): Kriteria Cost + Alternatif Identik (Tie)
- **Label:** `cross-checked`
- **Deskripsi:** Kasus tepi alternatif kembar dengan jarak solusi ideal sempurna (1.0).
- **Kriteria:**
  - $C_1$: Biaya (Cost, Bobot = 50%, Nilai Max = 100)
  - $C_2$: Kualitas (Benefit, Bobot = 50%, Nilai Max = 100)
- **Matriks Keputusan ($X$):**
  - $A_1$: `[30, 80]`
  - $A_2$: `[30, 80]` (identik)
  - $A_3$: `[50, 60]`
- **Skor Akhir & Perilaku Peringkat:**
  - $A_1$: $D^+ = 0.000000$, $D^- = 0.171328$, Skor = `1.000000`, Peringkat = 1
  - $A_2$: $D^+ = 0.000000$, $D^- = 0.171328$, Skor = `1.000000`, Peringkat = 2
  - $A_3$: $D^+ = 0.171328$, $D^- = 0.000000$, Skor = `0.000000`, Peringkat = 3
  - *Catatan Kasus Tie:*
    - Perilaku saat ini: rank unik sekuensial (1, 2, 3, ...), urutan alternatif seri mengikuti urutan input pada ukuran data kecil.
    - Catatan: `List.sort` Dart tidak dijamin stabil, sehingga urutan alternatif seri pada data besar tidak dijamin.
    - Item terbuka: putuskan semantik rank saat seri (rank sama vs rank unik) dan tiebreak eksplisit.

---

## 3. Analytic Hierarchy Process (AHP)

### Kasus 1: Consistent 3x3 case
- **Label:** `cross-checked`
- **Kriteria (3 kriteria):** $C_1$ (Biaya), $C_2$ (Kualitas), $C_3$ (Pengiriman)
  - Perbandingan Kriteria:
    - $C_1$ vs $C_2$: Skala 3 ($C_1$ lebih penting)
    - $C_1$ vs $C_3$: Skala 5 ($C_1$ lebih penting)
    - $C_2$ vs $C_3$: Skala 2 ($C_2$ lebih penting)
- **Hasil Kriteria:**
  - Bobot Kriteria: `[0.647947, 0.229871, 0.122182]`
  - $\lambda_{max} = 3.003697$
  - $CI = 0.001848$
  - $CR = 0.003187$ (Konsisten karena $CR \le 0.1$)
- **Alternatif (3 alternatif: $A, B, C$):**
  - Perbandingan di bawah $C_1$: $A$ vs $B = 2$, $A$ vs $C = 5$, $B$ vs $C = 3$
    - Prioritas: `[0.581264, 0.309150, 0.109586]`, $CR = 0.003186$
  - Perbandingan di bawah $C_2$: $A$ vs $B = 1/3$ ($B$ lebih penting skala 3), $A$ vs $C = 2$, $B$ vs $C = 4$
    - Prioritas: `[0.239488, 0.623225, 0.137288]`, $CR = 0.015808$
  - Perbandingan di bawah $C_3$: $A$ vs $B = 1$, $A$ vs $C = 3$, $B$ vs $C = 3$
    - Prioritas: `[0.428571, 0.428571, 0.142857]`, $CR = 0.000000$
- **Skor Akhir & Peringkat:**
  - Alternatif $A$: Skor = `0.484043`, Peringkat = 1
  - Alternatif $B$: Skor = `0.395938`, Peringkat = 2
  - Alternatif $C$: Skor = `0.120019`, Peringkat = 3
  - Konsistensi: `isConsistentCriteria = true`, `isConsistentAlternative = true`, `note = null`

### Kasus 2: Candidate Selection - Multiple Levels
- **Label:** `cross-checked`
- **Kriteria:** $C_1$ (Pengalaman), $C_2$ (Teknis), $C_3$ (Wawancara)
  - $C_1$ vs $C_2$: Skala 2 ($C_1$ lebih penting)
  - $C_1$ vs $C_3$: Skala 4 ($C_1$ lebih penting)
  - $C_2$ vs $C_3$: Skala 3 ($C_2$ lebih penting)
- **Hasil Kriteria:**
  - Bobot Kriteria: `[0.557143, 0.320238, 0.122619]`
  - $\lambda_{max} = 3.018325$
  - $CI = 0.009162$
  - $CR = 0.015797$ ($CR \le 0.1$)
- **Alternatif (John, Mary, David):**
  - Prioritas under $C_1$: John = 0.647947, Mary = 0.229871, David = 0.122182 ($CR = 0.003187$)
  - Prioritas under $C_2$: John = 0.297258, Mary = 0.538961, David = 0.163781 ($CR = 0.007939$)
  - Prioritas under $C_3$: John = 0.297258, Mary = 0.163781, David = 0.538961 ($CR = 0.007939$)
- **Skor Akhir & Peringkat:**
  - John: Skor = `0.492642`, Peringkat = 1
  - Mary: Skor = `0.320750`, Peringkat = 2
  - David: Skor = `0.186609`, Peringkat = 3
  - Konsistensi: `isConsistentCriteria = true`, `isConsistentAlternative = true`, `note = null`

### Kasus 3 (Edge Case): Inconsistent Comparison Matrix with CR > 0.1
- **Label:** `cross-checked`
- **Kriteria:** $C_1, C_2, C_3$
  - $C_1$ vs $C_2$: Skala 9 ($C_1$ jauh lebih penting)
  - $C_2$ vs $C_3$: Skala 9 ($C_2$ jauh lebih penting)
  - $C_1$ vs $C_3$: Skala 1/9 ($C_3$ jauh lebih penting, kontradiksi sirkular!)
- **Hasil Kriteria:**
  - Bobot Kriteria: `[0.333333, 0.333333, 0.333333]`
  - $\lambda_{max} = 10.111111$
  - $CI = 3.555556$
  - $CR = 6.130268$ (Inkonsisten parah karena $CR \gg 0.1$)
- **Hasil Penilaian Akhir:**
  - `isConsistentCriteria = false`
  - `consistencyCriteriaRatio = 6.130268`
  - `note`: Mengandung teks peringatan `'inconsistency on criteria'` dan rekomendasi revisi.
