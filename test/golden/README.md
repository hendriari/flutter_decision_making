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
- **Bobot Ternormalisasi ($w$):**
  - $C_1$: `0.250000`, $C_2$: `0.250000`, $C_3$: `0.250000`, $C_4$: `0.250000` (jumlah = `1.000000`)
- **Matriks Terbobot ($V = R \times W$):**
  - $A_1$: `[0.250000, 0.250000, 0.194444, 0.250000]`
  - $A_2$: `[0.166667, 0.166667, 0.250000, 0.187500]`
  - $A_3$: `[0.125000, 0.250000, 0.166667, 0.107143]`
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
- **Matriks Ternormalisasi ($R$):**
  - $A_1$: `[0.888889, 0.777778, 1.000000]`
  - $A_2$: `[1.000000, 0.888889, 0.777778]`
  - $A_3$: `[0.833333, 1.000000, 0.944444]`
  - $A_4$: `[0.944444, 0.666667, 0.888889]`
- **Bobot Ternormalisasi ($w$):**
  - $C_1$: `0.400000`, $C_2$: `0.300000`, $C_3$: `0.300000` (jumlah = `1.000000`)
- **Matriks Terbobot ($V = R \times W$):**
  - $A_1$: `[0.355556, 0.233333, 0.300000]`
  - $A_2$: `[0.400000, 0.266667, 0.233333]`
  - $A_3$: `[0.333333, 0.300000, 0.283333]`
  - $A_4$: `[0.377778, 0.200000, 0.266667]`
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
- **Matriks Ternormalisasi ($R$):**
  - $A_1$: `[1.000000, 1.000000]`
  - $A_2$: `[1.000000, 1.000000]`
  - $A_3$: `[0.666667, 0.750000]`
- **Bobot Ternormalisasi ($w$):**
  - $C_1$: `0.500000`, $C_2$: `0.500000` (jumlah = `1.000000`)
- **Matriks Terbobot ($V = R \times W$):**
  - $A_1$: `[0.500000, 0.500000]`
  - $A_2$: `[0.500000, 0.500000]`
  - $A_3$: `[0.333333, 0.375000]`
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
- **Pembagi Euclidean:**
  - $C_1$: `13.674794`, $C_2$: `15.165751`, $C_3$: `12.845233`, $C_4$: `14.662878`
- **Matriks Ternormalisasi ($R$):**
  - $A_1$: `[0.365636, 0.527504, 0.311400, 0.477396]`
  - $A_2$: `[0.511891, 0.395628, 0.622799, 0.613795]`
  - $A_3$: `[0.585018, 0.593442, 0.467099, 0.409197]`
  - $A_4$: `[0.511891, 0.461566, 0.544949, 0.477396]`
- **Bobot Ternormalisasi ($w$):**
  - $C_1$: `0.300000`, $C_2$: `0.200000`, $C_3$: `0.250000`, $C_4$: `0.250000`
- **Matriks Terbobot ($V = R \times W$):**
  - $A_1$: `[0.109691, 0.105501, 0.077850, 0.119349]`
  - $A_2$: `[0.153567, 0.079126, 0.155700, 0.153449]`
  - $A_3$: `[0.175505, 0.118688, 0.116775, 0.102299]`
  - $A_4$: `[0.153567, 0.092313, 0.136237, 0.119349]`
- **Solusi Ideal Positif ($A^+$) & Negatif ($A^-$):**
  - $A^+$: `[0.175505, 0.118688, 0.155700, 0.102299]`
  - $A^-$: `[0.109691, 0.079126, 0.077850, 0.153449]`
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
- **Pembagi Euclidean:**
  - $C_1$: `139.283883`, $C_2$: `39.051248`, $C_3$: `19.723083`
- **Matriks Ternormalisasi ($R$):**
  - $S_1$: `[0.574367, 0.512148, 0.507020]`
  - $S_2$: `[0.646162, 0.768221, 0.760530]`
  - $S_3$: `[0.502571, 0.384111, 0.405616]`
- **Bobot Ternormalisasi ($w$):**
  - $C_1$: `0.500000`, $C_2$: `0.300000`, $C_3$: `0.200000`
- **Matriks Terbobot ($V = R \times W$):**
  - $S_1$: `[0.287183, 0.153644, 0.101404]`
  - $S_2$: `[0.323081, 0.230466, 0.152106]`
  - $S_3$: `[0.251285, 0.115233, 0.081123]`
- **Solusi Ideal Positif ($A^+$) & Negatif ($A^-$):**
  - $A^+$: `[0.323081, 0.115233, 0.081123]`
  - $A^-$: `[0.251285, 0.230466, 0.152106]`
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
- **Pembagi Euclidean:**
  - $C_1$: `65.574385`, $C_2$: `128.062485`
- **Matriks Ternormalisasi ($R$):**
  - $A_1$: `[0.457496, 0.624695]`
  - $A_2$: `[0.457496, 0.624695]`
  - $A_3$: `[0.762493, 0.468521]`
- **Bobot Ternormalisasi ($w$):**
  - $C_1$: `0.500000`, $C_2$: `0.500000`
- **Matriks Terbobot ($V = R \times W$):**
  - $A_1$: `[0.228748, 0.312348]`
  - $A_2$: `[0.228748, 0.312348]`
  - $A_3$: `[0.381246, 0.234261]`
- **Solusi Ideal Positif ($A^+$) & Negatif ($A^-$):**
  - $A^+$: `[0.228748, 0.312348]`
  - $A^-$: `[0.381246, 0.234261]`
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
  - **Matriks Perbandingan Kriteria ($A$):**
    $$\begin{pmatrix} 1.0 & 3.0 & 5.0 \\ 0.333333 & 1.0 & 2.0 \\ 0.2 & 0.5 & 1.0 \end{pmatrix}$$
  - **Jumlah Kolom (Column Sums):** `[1.533333, 4.500000, 8.000000]`
  - **Matriks Ternormalisasi ($N$):**
    - Baris 1: `[0.652174, 0.666667, 0.625000]`
    - Baris 2: `[0.217391, 0.222222, 0.250000]`
    - Baris 3: `[0.130435, 0.111111, 0.125000]`
  - **Bobot Kriteria (Column Averaging vs Eigenvector Eksak):**
    - $w_{\text{avg}}$: `[0.647947, 0.229871, 0.122182]`
    - $w_{\text{exact}}$: `[0.648329, 0.229651, 0.122020]`
    - Selisih ($w_{\text{avg}} - w_{\text{exact}}$): `[-0.000382, +0.000220, +0.000162]`
  - **Metrik Konsistensi Kriteria:**
    - $\lambda_{\max} = 3.003697$ (Eksak: $3.003695$)
    - $CI = 0.001848$
    - $RI = 0.58$ (Saaty $n=3$)
    - $CR = 0.003187$ (Konsisten karena $CR \le 0.1$)

- **Alternatif (3 alternatif: $A, B, C$):**
  - **Di bawah $C_1$ (Biaya):** $A$ vs $B = 2$, $A$ vs $C = 5$, $B$ vs $C = 3$
    - Matriks $A$: `[[1.0, 2.0, 5.0], [0.5, 1.0, 3.0], [0.2, 0.333333, 1.0]]`
    - Column sums: `[1.700000, 3.333333, 9.000000]`
    - Matriks Ternormalisasi $N$:
      - `[0.588235, 0.600000, 0.555556]`
      - `[0.294118, 0.300000, 0.333333]`
      - `[0.117647, 0.100000, 0.111111]`
    - Prioritas $w_{\text{avg}}$: `[0.581264, 0.309150, 0.109586]`
    - Prioritas $w_{\text{exact}}$: `[0.581552, 0.308996, 0.109452]` (Selisih: `[-0.000288, +0.000155, +0.000134]`)
    - Konsistensi: $\lambda_{\max} = 3.003696$, $CI = 0.001848$, $CR = 0.003186$ ($CR \le 0.1$)
  - **Di bawah $C_2$ (Kualitas):** $A$ vs $B = 1/3$ ($B$ lebih penting skala 3), $A$ vs $C = 2$, $B$ vs $C = 4$
    - Matriks $A$: `[[1.0, 0.333333, 2.0], [3.0, 1.0, 4.0], [0.5, 0.25, 1.0]]`
    - Column sums: `[4.500000, 1.583333, 7.000000]`
    - Matriks Ternormalisasi $N$:
      - `[0.222222, 0.210526, 0.285714]`
      - `[0.666667, 0.631579, 0.571429]`
      - `[0.111111, 0.157895, 0.142857]`
    - Prioritas $w_{\text{avg}}$: `[0.239488, 0.623225, 0.137288]`
    - Prioritas $w_{\text{exact}}$: `[0.238487, 0.625013, 0.136500]` (Selisih: `[+0.001000, -0.001788, +0.000788]`)
    - Konsistensi: $\lambda_{\max} = 3.018337$, $CI = 0.009169$, $CR = 0.015808$ ($CR \le 0.1$)
  - **Di bawah $C_3$ (Pengiriman):** $A$ vs $B = 1$, $A$ vs $C = 3$, $B$ vs $C = 3$
    - Matriks $A$: `[[1.0, 1.0, 3.0], [1.0, 1.0, 3.0], [0.333333, 0.333333, 1.0]]`
    - Column sums: `[2.333333, 2.333333, 7.000000]`
    - Matriks Ternormalisasi $N$:
      - `[0.428571, 0.428571, 0.428571]`
      - `[0.428571, 0.428571, 0.428571]`
      - `[0.142857, 0.142857, 0.142857]`
    - Prioritas $w_{\text{avg}}$: `[0.428571, 0.428571, 0.142857]`
    - Prioritas $w_{\text{exact}}$: `[0.428571, 0.428571, 0.142857]` (Selisih: `0.0`)
    - Konsistensi: $\lambda_{\max} = 3.000000$, $CI = 0.000000$, $CR = 0.000000$ ($CR \le 0.1$)

- **Sintesis Skor Akhir & Peringkat:**
  - $A$: Skor Column Averaging = **`0.484043`** | Skor Eigenvector Eksak = **`0.484100`** (Selisih: `-0.000057`) | Peringkat = **1**
  - $B$: Skor Column Averaging = **`0.395938`** | Skor Eigenvector Eksak = **`0.396160`** (Selisih: `-0.000222`) | Peringkat = **2**
  - $C$: Skor Column Averaging = **`0.120019`** | Skor Eigenvector Eksak = **`0.119740`** (Selisih: `+0.000279`) | Peringkat = **3**
  - Konsistensi Keseluruhan: `isConsistentCriteria = true`, `isConsistentAlternative = true`, `isConsistent = true`, `note = null`

---

### Kasus 2: Candidate Selection - Multiple Levels
- **Label:** `cross-checked`
- **Kriteria (3 kriteria):** $C_1$ (Pengalaman), $C_2$ (Teknis), $C_3$ (Wawancara)
  - **Matriks Perbandingan Kriteria ($A$):**
    $$\begin{pmatrix} 1.0 & 2.0 & 4.0 \\ 0.5 & 1.0 & 3.0 \\ 0.25 & 0.333333 & 1.0 \end{pmatrix}$$
  - **Jumlah Kolom (Column Sums):** `[1.750000, 3.333333, 8.000000]`
  - **Matriks Ternormalisasi ($N$):**
    - Baris 1: `[0.571429, 0.600000, 0.500000]`
    - Baris 2: `[0.285714, 0.300000, 0.375000]`
    - Baris 3: `[0.142857, 0.100000, 0.125000]`
  - **Bobot Kriteria (Column Averaging vs Eigenvector Eksak):**
    - $w_{\text{avg}}$: `[0.557143, 0.320238, 0.122619]`
    - $w_{\text{exact}}$: `[0.558425, 0.319618, 0.121957]`
    - Selisih ($w_{\text{avg}} - w_{\text{exact}}$): `[-0.001282, +0.000620, +0.000662]`
  - **Metrik Konsistensi Kriteria:**
    - $\lambda_{\max} = 3.018325$ (Eksak: $3.018295$)
    - $CI = 0.009162$
    - $RI = 0.58$ (Saaty $n=3$)
    - $CR = 0.015797$ ($CR \le 0.1$)

- **Alternatif (John, Mary, David):**
  - **Di bawah $C_1$ (Pengalaman):** John > Mary (3), John > David (5), Mary > David (2)
    - Matriks $A$: `[[1.0, 3.0, 5.0], [0.333333, 1.0, 2.0], [0.2, 0.5, 1.0]]`
    - Prioritas $w_{\text{avg}}$: `[0.647947, 0.229871, 0.122182]`
    - Prioritas $w_{\text{exact}}$: `[0.648329, 0.229651, 0.122020]` (Selisih: `[-0.000382, +0.000220, +0.000162]`)
    - Konsistensi: $\lambda_{\max} = 3.003697$, $CI = 0.001848$, $CR = 0.003187$
  - **Di bawah $C_2$ (Teknis):** Mary > John (2), John > David (2), Mary > David (3)
    - Matriks $A$: `[[1.0, 0.5, 2.0], [2.0, 1.0, 3.0], [0.5, 0.333333, 1.0]]`
    - Column sums: `[3.500000, 1.833333, 6.000000]`
    - Matriks Ternormalisasi $N$:
      - `[0.285714, 0.272727, 0.333333]`
      - `[0.571429, 0.545455, 0.500000]`
      - `[0.142857, 0.181818, 0.166667]`
    - Prioritas $w_{\text{avg}}$: `[0.297258, 0.538961, 0.163781]`
    - Prioritas $w_{\text{exact}}$: `[0.296961, 0.539615, 0.163424]` (Selisih: `[+0.000297, -0.000654, +0.000357]`)
    - Konsistensi: $\lambda_{\max} = 3.009209$, $CI = 0.004604$, $CR = 0.007939$
  - **Di bawah $C_3$ (Wawancara):** John > Mary (2), David > John (2), David > Mary (3)
    - Matriks $A$: `[[1.0, 2.0, 0.5], [0.5, 1.0, 0.333333], [2.0, 3.0, 1.0]]`
    - Column sums: `[3.500000, 6.000000, 1.833333]`
    - Matriks Ternormalisasi $N$:
      - `[0.285714, 0.333333, 0.272727]`
      - `[0.142857, 0.166667, 0.181818]`
      - `[0.571429, 0.500000, 0.545455]`
    - Prioritas $w_{\text{avg}}$: `[0.297258, 0.163781, 0.538961]`
    - Prioritas $w_{\text{exact}}$: `[0.296961, 0.163424, 0.539615]` (Selisih: `[+0.000297, +0.000357, -0.000654]`)
    - Konsistensi: $\lambda_{\max} = 3.009209$, $CI = 0.004604$, $CR = 0.007939$

- **Sintesis Skor Akhir & Peringkat:**
  - John: Skor Column Averaging = **`0.492642`** | Skor Eigenvector Eksak = **`0.493174`** (Selisih: `-0.000532`) | Peringkat = **1**
  - Mary: Skor Column Averaging = **`0.320750`** | Skor Eigenvector Eksak = **`0.320644`** (Selisih: `+0.000106`) | Peringkat = **2**
  - David: Skor Column Averaging = **`0.186609`** | Skor Eigenvector Eksak = **`0.186182`** (Selisih: `+0.000426`) | Peringkat = **3**
  - Konsistensi Keseluruhan: `isConsistentCriteria = true`, `isConsistentAlternative = true`, `isConsistent = true`, `note = null`

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
