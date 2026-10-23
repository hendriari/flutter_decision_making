# Golden Tests Documentation

This document records the input specifications, calculation results, and expected values for each golden test case in the `flutter_decision_making` and `decision_making_core` packages.

---

## Verification

Expected values were computed using a pure Python script and independently verified with NumPy (`np.linalg.eig` for AHP) during an independent review. The case datasets below are not citations from published textbooks or journals, but rather independently verified benchmark cases (*cross-checked*).

- **Label:** `cross-checked`
- **Numerical comparison tolerance:** `1e-4` (`closeTo(expected, 1e-4)`).

---

## AHP Limitations

1. **Weight Calculation Method:**
   This package implements the **Normalized Column Averaging** approximation method (normalizing column sums, then taking the row average), rather than exact matrix decomposition (*principal eigenvector*).
2. **Comparison with Exact Eigenvector (`np.linalg.eig`):**
   - **Case 1:**
     - Package weights (column averaging): `[0.647947, 0.229871, 0.122182]`, $\lambda_{max} = 3.003697$
     - Exact eigenvector: `[0.648329, 0.229651, 0.122020]`, $\lambda_{max} = 3.003695$
     - Weight difference: $\approx 3.8 \times 10^{-4}$ (negligible for consistent matrices).
   - **Case 2:**
     - Package weights (column averaging): `[0.557143, 0.320238, 0.122619]`, $\lambda_{max} = 3.018325$
     - Exact eigenvector: `[0.558425, 0.319618, 0.121957]`, $\lambda_{max} = 3.018295$
     - Weight difference: $\approx 1.3 \times 10^{-3}$.
   - **Conclusion:** For consistent comparison matrices ($CR \le 0.1$), the difference between the approximation and the true eigenvector ranges from $4 \times 10^{-4}$ to $1.3 \times 10^{-3}$. However, for inconsistent matrices ($CR > 0.1$), this divergence can be larger.
3. **Random Index (RI) & Matrix Size:**
   - The Random Index (RI) table in the package uses Saaty's table for $n = 1..15$.
   - For $n > 15$, a fixed fallback of `1.59` is used (`riTable[n] ?? 1.59`).
   - Estimated RI values from Monte Carlo simulations (random reciprocal matrices, 1/9..9 scale):
     - $n = 16 \approx 1.59$
     - $n = 20 \approx 1.62$
     - $n = 30 \approx 1.67$
     - $n = 50 \approx 1.71$
     - $n = 80 \approx 1.73$
   - Consequently, the Consistency Ratio ($CR = CI / RI$) for $n > 15$ becomes slightly more conservative (larger) than it should be.
   - Furthermore, AHP pairwise comparisons with many elements ($n > 15$) are practically unrealistic for human evaluators ($n(n-1)/2$ comparisons; e.g., $n=80$ requires 3,160 pairwise questions).

---

## 1. Simple Additive Weighting (SAW)

### Case 1: Mixed benefit and cost 3x4 case
- **Label:** `cross-checked`
- **Description:** Alternative selection across 4 mixed criteria (*benefit* and *cost*).
- **Criteria:**
  - $C_1$: Cost / Initial Investment (Cost, Weight = 25%, Max Value = 250)
  - $C_2$: Market Share (Benefit, Weight = 25%, Max Value = 5)
  - $C_3$: Capacity (Benefit, Weight = 25%, Max Value = 5000)
  - $C_4$: Risk Level (Cost, Weight = 25%, Max Value = 5)
- **Decision Matrix ($X$):**
  - $A_1$: `[100, 3, 3500, 1.5]`
  - $A_2$: `[150, 2, 4500, 2.0]`
  - $A_3$: `[200, 3, 3000, 3.5]`
- **Normalized Matrix ($R$):**
  - $A_1$: `[1.000000, 1.000000, 0.777778, 1.000000]`
  - $A_2$: `[0.666667, 0.666667, 1.000000, 0.750000]`
  - $A_3$: `[0.500000, 1.000000, 0.666667, 0.428571]`
- **Normalized Weights ($w$):**
  - $C_1$: `0.250000`, $C_2$: `0.250000`, $C_3$: `0.250000`, $C_4$: `0.250000` (sum = `1.000000`)
- **Weighted Matrix ($V = R \times W$):**
  - $A_1$: `[0.250000, 0.250000, 0.194444, 0.250000]`
  - $A_2$: `[0.166667, 0.166667, 0.250000, 0.187500]`
  - $A_3$: `[0.125000, 0.250000, 0.166667, 0.107143]`
- **Final Scores & Ranking:**
  - $A_1$: Score = `0.944444`, Rank = 1
  - $A_2$: Score = `0.770833`, Rank = 2
  - $A_3$: Score = `0.648810`, Rank = 3

### Case 2: Employee Performance Evaluation (All Benefit)
- **Label:** `cross-checked`
- **Criteria:**
  - $C_1$: Technical Skill (Benefit, Weight = 40%, Max Value = 100)
  - $C_2$: Communication (Benefit, Weight = 30%, Max Value = 100)
  - $C_3$: Attitude (Benefit, Weight = 30%, Max Value = 100)
- **Decision Matrix ($X$):**
  - $A_1$: `[80, 70, 90]`
  - $A_2$: `[90, 80, 70]`
  - $A_3$: `[75, 90, 85]`
  - $A_4$: `[85, 60, 80]`
- **Normalized Matrix ($R$):**
  - $A_1$: `[0.888889, 0.777778, 1.000000]`
  - $A_2$: `[1.000000, 0.888889, 0.777778]`
  - $A_3$: `[0.833333, 1.000000, 0.944444]`
  - $A_4$: `[0.944444, 0.666667, 0.888889]`
- **Normalized Weights ($w$):**
  - $C_1$: `0.400000`, $C_2$: `0.300000`, $C_3$: `0.300000` (sum = `1.000000`)
- **Weighted Matrix ($V = R \times W$):**
  - $A_1$: `[0.355556, 0.233333, 0.300000]`
  - $A_2$: `[0.400000, 0.266667, 0.233333]`
  - $A_3$: `[0.333333, 0.300000, 0.283333]`
  - $A_4$: `[0.377778, 0.200000, 0.266667]`
- **Final Scores & Ranking:**
  - $A_3$: Score = `0.916667`, Rank = 1
  - $A_2$: Score = `0.900000`, Rank = 2
  - $A_1$: Score = `0.888889`, Rank = 3
  - $A_4$: Score = `0.844444`, Rank = 4

### Case 3 (Edge Case): Cost Criteria + Two Identical Alternatives (Tie)
- **Label:** `cross-checked`
- **Description:** Edge case validating cost criteria and deterministic behavior during score ties.
- **Criteria:**
  - $C_1$: Price (Cost, Weight = 50%, Max Value = 100)
  - $C_2$: Quality (Benefit, Weight = 50%, Max Value = 100)
- **Decision Matrix ($X$):**
  - $A_1$: `[40, 80]`
  - $A_2$: `[40, 80]` (identical to $A_1$)
  - $A_3$: `[60, 60]`
- **Normalized Matrix ($R$):**
  - $A_1$: `[1.000000, 1.000000]`
  - $A_2$: `[1.000000, 1.000000]`
  - $A_3$: `[0.666667, 0.750000]`
- **Normalized Weights ($w$):**
  - $C_1$: `0.500000`, $C_2$: `0.500000` (sum = `1.000000`)
- **Weighted Matrix ($V = R \times W$):**
  - $A_1$: `[0.500000, 0.500000]`
  - $A_2$: `[0.500000, 0.500000]`
  - $A_3$: `[0.333333, 0.375000]`
- **Final Scores & Ranking Behavior:**
  - $A_1$: Score = `1.000000`, Rank = 1
  - $A_2$: Score = `1.000000`, Rank = 2
  - $A_3$: Score = `0.708333`, Rank = 3
  - *Tie Case Notes:*
    - Current behavior: sequential unique ranks (1, 2, 3, ...), tied alternative order follows input order on small datasets.
    - Note: Dart's `List.sort` is not guaranteed to be stable, so the order of tied alternatives on large datasets is not guaranteed.
    - Open item: decide tie-ranking semantics (equal rank vs unique rank) and explicit tiebreaking.

---

## 2. TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)

### Case 1: Consistent 4x4 case
- **Label:** `cross-checked`
- **Description:** 4 alternatives and 4 criteria with Euclidean normalization.
- **Criteria:**
  - $C_1$: Benefit, Weight = 30%, Max Value = 10
  - $C_2$: Benefit, Weight = 20%, Max Value = 10
  - $C_3$: Benefit, Weight = 25%, Max Value = 10
  - $C_4$: Cost, Weight = 25%, Max Value = 10
- **Decision Matrix ($X$):**
  - $A_1$: `[5, 8, 4, 7]`
  - $A_2$: `[7, 6, 8, 9]`
  - $A_3$: `[8, 9, 6, 6]`
  - $A_4$: `[7, 7, 7, 7]`
- **Euclidean Dividers:**
  - $C_1$: `13.674794`, $C_2$: `15.165751`, $C_3$: `12.845233`, $C_4$: `14.662878`
- **Normalized Matrix ($R$):**
  - $A_1$: `[0.365636, 0.527504, 0.311400, 0.477396]`
  - $A_2$: `[0.511891, 0.395628, 0.622799, 0.613795]`
  - $A_3$: `[0.585018, 0.593442, 0.467099, 0.409197]`
  - $A_4$: `[0.511891, 0.461566, 0.544949, 0.477396]`
- **Normalized Weights ($w$):**
  - $C_1$: `0.300000`, $C_2$: `0.200000`, $C_3$: `0.250000`, $C_4$: `0.250000`
- **Weighted Matrix ($V = R \times W$):**
  - $A_1$: `[0.109691, 0.105501, 0.077850, 0.119349]`
  - $A_2$: `[0.153567, 0.079126, 0.155700, 0.153449]`
  - $A_3$: `[0.175505, 0.118688, 0.116775, 0.102299]`
  - $A_4$: `[0.153567, 0.092313, 0.136237, 0.119349]`
- **Positive Ideal ($A^+$) & Negative Ideal ($A^-$) Solutions:**
  - $A^+$: `[0.175505, 0.118688, 0.155700, 0.102299]`
  - $A^-$: `[0.109691, 0.079126, 0.077850, 0.153449]`
- **Ideal Solution Distances & Relative Closeness Scores:**
  - $A_1$: $D^+ = 0.104196$, $D^- = 0.043110$, Score = `0.292655`, Rank = 4
  - $A_2$: $D^+ = 0.068285$, $D^- = 0.089363$, Score = `0.566853`, Rank = 3
  - $A_3$: $D^+ = 0.038925$, $D^- = 0.100141$, Score = `0.720097`, Rank = 1
  - $A_4$: $D^+ = 0.042970$, $D^- = 0.081676$, Score = `0.655263`, Rank = 2

### Case 2: Vendor / Supplier Selection (Multiple Cost Criteria)
- **Label:** `cross-checked`
- **Criteria:**
  - $C_1$: Product Quality (Benefit, Weight = 50%, Max Value = 100)
  - $C_2$: Price Quote (Cost, Weight = 30%, Max Value = 100)
  - $C_3$: Delivery Time (Cost, Weight = 20%, Max Value = 100)
- **Decision Matrix ($X$):**
  - $S_1$: `[80, 20, 10]`
  - $S_2$: `[90, 30, 15]`
  - $S_3$: `[70, 15, 8]`
- **Euclidean Dividers:**
  - $C_1$: `139.283883`, $C_2$: `39.051248`, $C_3$: `19.723083`
- **Normalized Matrix ($R$):**
  - $S_1$: `[0.574367, 0.512148, 0.507020]`
  - $S_2$: `[0.646162, 0.768221, 0.760530]`
  - $S_3$: `[0.502571, 0.384111, 0.405616]`
- **Normalized Weights ($w$):**
  - $C_1$: `0.500000`, $C_2$: `0.300000`, $C_3$: `0.200000`
- **Weighted Matrix ($V = R \times W$):**
  - $S_1$: `[0.287183, 0.153644, 0.101404]`
  - $S_2$: `[0.323081, 0.230466, 0.152106]`
  - $S_3$: `[0.251285, 0.115233, 0.081123]`
- **Positive Ideal ($A^+$) & Negative Ideal ($A^-$) Solutions:**
  - $A^+$: `[0.323081, 0.115233, 0.081123]`
  - $A^-$: `[0.251285, 0.230466, 0.152106]`
- **Final Scores & Ranking:**
  - $S_3$: $D^+ = 0.071796$, $D^- = 0.135341$, Score = `0.653390`, Rank = 1
  - $S_1$: $D^+ = 0.056351$, $D^- = 0.098798$, Score = `0.636796`, Rank = 2
  - $S_2$: $D^+ = 0.135341$, $D^- = 0.071796$, Score = `0.346610`, Rank = 3

### Case 3 (Edge Case): Cost Criteria + Identical Alternatives (Tie)
- **Label:** `cross-checked`
- **Description:** Edge case with identical alternatives and ideal solution distances reaching perfect extremes (1.0).
- **Criteria:**
  - $C_1$: Cost (Cost, Weight = 50%, Max Value = 100)
  - $C_2$: Quality (Benefit, Weight = 50%, Max Value = 100)
- **Decision Matrix ($X$):**
  - $A_1$: `[30, 80]`
  - $A_2$: `[30, 80]` (identical)
  - $A_3$: `[50, 60]`
- **Euclidean Dividers:**
  - $C_1$: `65.574385`, $C_2$: `128.062485`
- **Normalized Matrix ($R$):**
  - $A_1$: `[0.457496, 0.624695]`
  - $A_2$: `[0.457496, 0.624695]`
  - $A_3$: `[0.762493, 0.468521]`
- **Normalized Weights ($w$):**
  - $C_1$: `0.500000`, $C_2$: `0.500000`
- **Weighted Matrix ($V = R \times W$):**
  - $A_1$: `[0.228748, 0.312348]`
  - $A_2$: `[0.228748, 0.312348]`
  - $A_3$: `[0.381246, 0.234261]`
- **Positive Ideal ($A^+$) & Negative Ideal ($A^-$) Solutions:**
  - $A^+$: `[0.228748, 0.312348]`
  - $A^-$: `[0.381246, 0.234261]`
- **Final Scores & Ranking Behavior:**
  - $A_1$: $D^+ = 0.000000$, $D^- = 0.171328$, Score = `1.000000`, Rank = 1
  - $A_2$: $D^+ = 0.000000$, $D^- = 0.171328$, Score = `1.000000`, Rank = 2
  - $A_3$: $D^+ = 0.171328$, $D^- = 0.000000$, Score = `0.000000`, Rank = 3
  - *Tie Case Notes:*
    - Current behavior: sequential unique ranks (1, 2, 3, ...), tied alternative order follows input order on small datasets.
    - Note: Dart's `List.sort` is not guaranteed to be stable, so the order of tied alternatives on large datasets is not guaranteed.
    - Open item: decide tie-ranking semantics (equal rank vs unique rank) and explicit tiebreaking.

---

## 3. Analytic Hierarchy Process (AHP)

### Case 1: Consistent 3x3 case
- **Label:** `cross-checked`
- **Criteria (3 criteria):** $C_1$ (Cost), $C_2$ (Quality), $C_3$ (Delivery)
  - **Criteria Pairwise Comparison Matrix ($A$):**
    $$\begin{pmatrix} 1.0 & 3.0 & 5.0 \\ 0.333333 & 1.0 & 2.0 \\ 0.2 & 0.5 & 1.0 \end{pmatrix}$$
  - **Column Sums:** `[1.533333, 4.500000, 8.000000]`
  - **Normalized Matrix ($N$):**
    - Row 1: `[0.652174, 0.666667, 0.625000]`
    - Row 2: `[0.217391, 0.222222, 0.250000]`
    - Row 3: `[0.130435, 0.111111, 0.125000]`
  - **Criteria Weights (Column Averaging vs Exact Eigenvector):**
    - $w_{\text{avg}}$: `[0.647947, 0.229871, 0.122182]`
    - $w_{\text{exact}}$: `[0.648329, 0.229651, 0.122020]`
    - Difference ($w_{\text{avg}} - w_{\text{exact}}$): `[-0.000382, +0.000220, +0.000162]`
  - **Criteria Consistency Metrics:**
    - $\lambda_{\max} = 3.003697$ (Exact: $3.003695$)
    - $CI = 0.001848$
    - $RI = 0.58$ (Saaty $n=3$)
    - $CR = 0.003187$ (Consistent since $CR \le 0.1$)

- **Alternatives (3 alternatives: $A, B, C$):**
  - **Under $C_1$ (Cost):** $A$ vs $B = 2$, $A$ vs $C = 5$, $B$ vs $C = 3$
    - Matrix $A$: `[[1.0, 2.0, 5.0], [0.5, 1.0, 3.0], [0.2, 0.333333, 1.0]]`
    - Column sums: `[1.700000, 3.333333, 9.000000]`
    - Normalized Matrix $N$:
      - `[0.588235, 0.600000, 0.555556]`
      - `[0.294118, 0.300000, 0.333333]`
      - `[0.117647, 0.100000, 0.111111]`
    - Priorities $w_{\text{avg}}$: `[0.581264, 0.309150, 0.109586]`
    - Priorities $w_{\text{exact}}$: `[0.581552, 0.308996, 0.109452]` (Difference: `[-0.000288, +0.000155, +0.000134]`)
    - Consistency: $\lambda_{\max} = 3.003696$, $CI = 0.001848$, $CR = 0.003186$ ($CR \le 0.1$)
  - **Under $C_2$ (Quality):** $A$ vs $B = 1/3$ ($B$ is more important on scale 3), $A$ vs $C = 2$, $B$ vs $C = 4$
    - Matrix $A$: `[[1.0, 0.333333, 2.0], [3.0, 1.0, 4.0], [0.5, 0.25, 1.0]]`
    - Column sums: `[4.500000, 1.583333, 7.000000]`
    - Normalized Matrix $N$:
      - `[0.222222, 0.210526, 0.285714]`
      - `[0.666667, 0.631579, 0.571429]`
      - `[0.111111, 0.157895, 0.142857]`
    - Priorities $w_{\text{avg}}$: `[0.239488, 0.623225, 0.137288]`
    - Priorities $w_{\text{exact}}$: `[0.238487, 0.625013, 0.136500]` (Difference: `[+0.001000, -0.001788, +0.000788]`)
    - Consistency: $\lambda_{\max} = 3.018337$, $CI = 0.009169$, $CR = 0.015808$ ($CR \le 0.1$)
  - **Under $C_3$ (Delivery):** $A$ vs $B = 1$, $A$ vs $C = 3$, $B$ vs $C = 3$
    - Matrix $A$: `[[1.0, 1.0, 3.0], [1.0, 1.0, 3.0], [0.333333, 0.333333, 1.0]]`
    - Column sums: `[2.333333, 2.333333, 7.000000]`
    - Normalized Matrix $N$:
      - `[0.428571, 0.428571, 0.428571]`
      - `[0.428571, 0.428571, 0.428571]`
      - `[0.142857, 0.142857, 0.142857]`
    - Priorities $w_{\text{avg}}$: `[0.428571, 0.428571, 0.142857]`
    - Priorities $w_{\text{exact}}$: `[0.428571, 0.428571, 0.142857]` (Difference: `0.0`)
    - Consistency: $\lambda_{\max} = 3.000000$, $CI = 0.000000$, $CR = 0.000000$ ($CR \le 0.1$)

- **Final Score Synthesis & Ranking:**
  - $A$: Column Averaging Score = **`0.484043`** | Exact Eigenvector Score = **`0.484100`** (Difference: `-0.000057`) | Rank = **1**
  - $B$: Column Averaging Score = **`0.395938`** | Exact Eigenvector Score = **`0.396160`** (Difference: `-0.000222`) | Rank = **2**
  - $C$: Column Averaging Score = **`0.120019`** | Exact Eigenvector Score = **`0.119740`** (Difference: `+0.000279`) | Rank = **3**
  - Overall Consistency: `isConsistentCriteria = true`, `isConsistentAlternative = true`, `isConsistent = true`, `note = null`

---

### Case 2: Candidate Selection - Multiple Levels
- **Label:** `cross-checked`
- **Criteria (3 criteria):** $C_1$ (Experience), $C_2$ (Technical), $C_3$ (Interview)
  - **Criteria Pairwise Comparison Matrix ($A$):**
    $$\begin{pmatrix} 1.0 & 2.0 & 4.0 \\ 0.5 & 1.0 & 3.0 \\ 0.25 & 0.333333 & 1.0 \end{pmatrix}$$
  - **Column Sums:** `[1.750000, 3.333333, 8.000000]`
  - **Normalized Matrix ($N$):**
    - Row 1: `[0.571429, 0.600000, 0.500000]`
    - Row 2: `[0.285714, 0.300000, 0.375000]`
    - Row 3: `[0.142857, 0.100000, 0.125000]`
  - **Criteria Weights (Column Averaging vs Exact Eigenvector):**
    - $w_{\text{avg}}$: `[0.557143, 0.320238, 0.122619]`
    - $w_{\text{exact}}$: `[0.558425, 0.319618, 0.121957]`
    - Difference ($w_{\text{avg}} - w_{\text{exact}}$): `[-0.001282, +0.000620, +0.000662]`
  - **Criteria Consistency Metrics:**
    - $\lambda_{\max} = 3.018325$ (Exact: $3.018295$)
    - $CI = 0.009162$
    - $RI = 0.58$ (Saaty $n=3$)
    - $CR = 0.015797$ ($CR \le 0.1$)

- **Alternatives (John, Mary, David):**
  - **Under $C_1$ (Experience):** John > Mary (3), John > David (5), Mary > David (2)
    - Matrix $A$: `[[1.0, 3.0, 5.0], [0.333333, 1.0, 2.0], [0.2, 0.5, 1.0]]`
    - Priorities $w_{\text{avg}}$: `[0.647947, 0.229871, 0.122182]`
    - Priorities $w_{\text{exact}}$: `[0.648329, 0.229651, 0.122020]` (Difference: `[-0.000382, +0.000220, +0.000162]`)
    - Consistency: $\lambda_{\max} = 3.003697$, $CI = 0.001848$, $CR = 0.003187$
  - **Under $C_2$ (Technical):** Mary > John (2), John > David (2), Mary > David (3)
    - Matrix $A$: `[[1.0, 0.5, 2.0], [2.0, 1.0, 3.0], [0.5, 0.333333, 1.0]]`
    - Column sums: `[3.500000, 1.833333, 6.000000]`
    - Normalized Matrix $N$:
      - `[0.285714, 0.272727, 0.333333]`
      - `[0.571429, 0.545455, 0.500000]`
      - `[0.142857, 0.181818, 0.166667]`
    - Priorities $w_{\text{avg}}$: `[0.297258, 0.538961, 0.163781]`
    - Priorities $w_{\text{exact}}$: `[0.296961, 0.539615, 0.163424]` (Difference: `[+0.000297, -0.000654, +0.000357]`)
    - Consistency: $\lambda_{\max} = 3.009209$, $CI = 0.004604$, $CR = 0.007939$
  - **Under $C_3$ (Interview):** John > Mary (2), David > John (2), David > Mary (3)
    - Matrix $A$: `[[1.0, 2.0, 0.5], [0.5, 1.0, 0.333333], [2.0, 3.0, 1.0]]`
    - Column sums: `[3.500000, 6.000000, 1.833333]`
    - Normalized Matrix $N$:
      - `[0.285714, 0.333333, 0.272727]`
      - `[0.142857, 0.166667, 0.181818]`
      - `[0.571429, 0.500000, 0.545455]`
    - Priorities $w_{\text{avg}}$: `[0.297258, 0.163781, 0.538961]`
    - Priorities $w_{\text{exact}}$: `[0.296961, 0.163424, 0.539615]` (Difference: `[+0.000297, +0.000357, -0.000654]`)
    - Consistency: $\lambda_{\max} = 3.009209$, $CI = 0.004604$, $CR = 0.007939$

- **Final Score Synthesis & Ranking:**
  - John: Column Averaging Score = **`0.492642`** | Exact Eigenvector Score = **`0.493174`** (Difference: `-0.000532`) | Rank = **1**
  - Mary: Column Averaging Score = **`0.320750`** | Exact Eigenvector Score = **`0.320644`** (Difference: `+0.000106`) | Rank = **2**
  - David: Column Averaging Score = **`0.186609`** | Exact Eigenvector Score = **`0.186182`** (Difference: `+0.000426`) | Rank = **3**
  - Overall Consistency: `isConsistentCriteria = true`, `isConsistentAlternative = true`, `isConsistent = true`, `note = null`

---

### Case 3 (Edge Case): Inconsistent Comparison Matrix with CR > 0.1
- **Label:** `cross-checked`
- **Criteria:** $C_1, C_2, C_3$
  - $C_1$ vs $C_2$: Scale 9 ($C_1$ is extremely more important)
  - $C_2$ vs $C_3$: Scale 9 ($C_2$ is extremely more important)
  - $C_1$ vs $C_3$: Scale 1/9 ($C_3$ is extremely more important, circular contradiction!)
- **Criteria Results:**
  - Criteria Weights: `[0.333333, 0.333333, 0.333333]`
  - $\lambda_{max} = 10.111111$
  - $CI = 3.555556$
  - $CR = 6.130268$ (Severely inconsistent because $CR \gg 0.1$)
- **Final Evaluation Results:**
  - `isConsistentCriteria = false`
  - `consistencyCriteriaRatio = 6.130268`
  - `note`: Contains warning text `'inconsistency on criteria'` and revision recommendations.
