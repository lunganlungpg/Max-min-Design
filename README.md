# MaxMin Design: Binary Treatment Comparisons
**Comprehensive Experimental Design & Optimization Suite for Max–Min Pairwise Allocations with Binary Outcomes**

---

### 👨‍🔬 Authorship & Academic Credentials
- **Research Innovations, Methodology & Software Suite**:  
  **Lunganlung P G**, Agricultural Statistics, 
  *ICAR - Indian Agricultural Statistics Research Institute (ICAR-IASRI)*  
  Library Avenue, Pusa, New Delhi – 110012, India.

- **Foundational Theoretical Research & Base Paper**:  
  **Satya Prakash Singh**<sup>a</sup> and **Ori Davidov**<sup>b</sup> (2026)  
  *"Max–min experimental designs for comparing pairs of treatments with binary outcomes"*  
  ***Journal of Statistical Planning and Inference***, Volume 243, Article 106379.  
  DOI: [10.1016/j.jspi.2025.106379](https://doi.org/10.1016/j.jspi.2025.106379)  
  - <sup>a</sup> *ICAR - Indian Agricultural Statistics Research Institute, New Delhi 110012, India*  
  - <sup>b</sup> *Department of Statistics, University of Haifa, Haifa 3498838, Israel*

---

## 📚 Foundational Theory (Singh & Davidov, 2026)

In experimental studies where multiple treatments are evaluated against one another with binary responses (success/failure, germination/non-germination, disease/cure), standard equal sample-size allocations are often statistically inefficient. 

**Singh and Davidov (2026)** established the theoretical foundations of max-min power-optimal designs:
1. **Comparison Graph Representation**: Experimental groups are vertices $V = \{1, \dots, K\}$ and requested pairwise comparisons are edges $P \subseteq V \times V$.
2. **Wald Test Invariance (Theorem 2.1)**: The Wald-type test statistic:
   $$T = R \hat{\theta}^T (R \hat{\Sigma} R^T)^{-1} R \hat{\theta}$$
   is strictly invariant to the choice of any $(K-1)$ linearly independent contrast basis rows of $R$.
3. **Exact Non-Centrality Parameter (Equation 9)**: Under sample allocation vector $n = (n_1, \dots, n_K)^T$ and success probabilities $\theta = (\theta_1, \dots, \theta_K)^T$:
   $$\phi(n; \theta) = \sum_{j=1}^{K-1} w_j(\theta_j - \theta_K)^2 - \frac{\left(\sum_{j=1}^{K-1} w_j(\theta_j - \theta_K)\right)^2}{\sum_{j=1}^K w_j}, \quad \text{where } w_j = \frac{n_j}{\theta_j(1 - \theta_j)}$$
4. **Degree-Based Allocation for Bipartite Graphs (Theorem 3.3)**: For any connected bipartite comparison graph, the max-min allocation vector $\xi = (\xi_1, \dots, \xi_K)^T$ is proportional to the vertex degrees:
   $$\xi_i = \frac{d_i}{2|P|}$$
   This splits observations equally (50% / 50%) between the two bipartite partitions while allocating units within each partition proportional to comparison intensity.
5. **Least Favourable Configurations (LFC)**: Identifying worst-case parameter configurations under the constraint $\max_{(i,j) \in P} |\theta_i - \theta_j| \ge \delta$. Unlike normal responses, the Bernoulli variance $\theta(1-\theta)$ is tied to the mean, shifting the LFC toward extreme variance boundaries.

---

## 💡 Research Innovations & Methodological Extensions by Lunganlung P G

To bridge the gap between abstract mathematical derivations and real-world agricultural and laboratory trial execution, **Lunganlung P G** developed six original contributions and extensions integrated into this suite:

### 1. Agricultural Translation & 5-Treatment Seed-Emergence Experimental Framework
- **Innovation**: Translated theoretical formulation into an agricultural seed-treatment experiment evaluating 5 distinct groups:
  1. Untreated Control
  2. Hydro-priming
  3. Bio-priming
  4. Fungicide dressing
  5. Integrated seed treatment
- **Impact**: Demonstrated on $N = 480$ seeds that comparison Graph (b) achieves a **30.88% seed savings** (reducing sample size requirement from 693 to 479 seeds for 90% power) by concentrating vertex degree on the Untreated Control and Bio-priming.

### 2. Discrete Integer Hamilton-Hare Exact Allocation Engine
- **Innovation**: Continuous asymptotic theory provides fractional allocations $\xi_i \in (0, 1)$, but agronomists and biologists cannot plant fractional seeds or allocate fractional plots.
- **Impact**: Developed and implemented an integer solver based on the **Hamilton-Hare Largest Remainder Method with Degree Preservation**. It guarantees that $\sum_{i=1}^K n_i = N$ exactly while maintaining minimal variance and preventing power loss caused by arbitrary rounding.

### 3. Dynamic Comparison Graph Topology Engine with Automated Bipartite & Connectivity Detection
- **Innovation**: While textbook literature analyzes fixed graph families, real research projects frequently require non-standard comparison structures.
- **Impact**: Engineered an interactive $K \times K$ adjacency matrix editor featuring real-time:
  - **Breadth-First Search (BFS) 2-Coloring**: Automatically detects whether a custom user-defined comparison graph is bipartite.
  - **Cut-Vertex / Bridge Detection**: Validates connected components to guarantee that the contrast rank remains $K - 1$.
  - Instantaneous degree calculation $d_i$ and automatic max-min sample size derivation.

### 4. 2D Multi-Parametric Power Sensitivity & Robustness Explorer
- **Innovation**: Evaluates design resilience against uncertain prior response rates.
- **Impact**: Constructed a 2D sensitivity matrix surface mapping control baseline rates ($\theta_c \in [0.20, 0.60]$) against effect sizes ($\delta \in [0.15, 0.45]$) under Poisson-mixture non-central $\chi^2$ CDF inversion. This allows researchers to verify that sample size allocations remain robust before planting.

### 5. Operational Field & Laboratory Randomized Plot Layout Engine
- **Innovation**: Statistical design requires operational randomization to avoid experimental bias in the field.
- **Impact**: Engineered a randomization tool using the **Fisher-Yates algorithm** that converts the optimal group sizes $(n_1, \dots, n_K)$ directly into randomized plot and nursery tray assignments. Includes real-time search filtering, downloadable CSV field plans, and printable PDF layouts.

### 6. Cross-Platform Deployable Ecosystem (Mobile Android APK + PWA + Reproducibility Packages)
- **Innovation**: Theoretical tools often remain locked in specialized statistical software unavailable in the field.
- **Impact**: Built a standalone signed Android APK (`MaxMinDesign.apk`, API 21–35) with native Android PrintManager, MediaStore, and ShareSheet integrations, a Progressive Web App (PWA) with offline Service Worker caching, and reproducible R 4.5.1 and Python 3.12 packages for open science.

---

## 📦 Project Deliverables

| Deliverable | File | Description |
| :--- | :--- | :--- |
| **Android APK** | [MaxMinDesign.apk](MaxMinDesign.apk) | **Version 1.2.0** — Signed production APK with offline mathematical engine, interactive graph matrix, 2D sensitivity heatmap, field randomizer, adaptive icons, and PDF/CSV export |
| **R Analysis Script** | [maxmin_designs.R](maxmin_designs.R) | Executable R 4.5.1 / RStudio script reproducing Section 4.2 simulations & Section 4.3 agricultural case study |
| **Python CLI Tool** | [maxmin_designs.py](maxmin_designs.py) | Standalone Python 3.12 command-line optimizer, simulator, and verification engine |
| **Web App / PWA** | [index.html](index.html), [app.js](app.js), [style.css](style.css) | Responsive mobile-friendly scientific web application with Service Worker offline caching |
| **Verification Suite** | [verify_apk.py](verify_apk.py) | Automated test suite validating APK integrity and cryptographic signatures |
| **Build Pipeline** | [build_apk.py](build_apk.py) | Automated Android build toolchain using AAPT2, javac, D8, zipalign & apksigner |

---

## 📱 Android Application (MaxMinDesign.apk)

The Android application operates **100% offline**, requiring zero internet connection once installed.

### Native Android Features:
- **Print / PDF Generator**: Connects to the Android system `PrintManager` to print or save the complete experimental trial protocol as a PDF document.
- **Save to Downloads**: Direct integration with Android `MediaStore` to save `.csv` allocation tables and `.txt` trial protocols into the device's public Downloads directory.
- **Android Share Sheet**: One-tap sharing of experimental protocols directly via WhatsApp, Gmail, SMS, or cloud drives.
- **Adaptive App Icons**: Supports full Android 8 through Android 15 icon standards (squircle, circle, and rounded rectangle).

---

## 💻 Running the R and Python Tools

### Run R Script (RStudio / R 4.5.1):
```bash
"C:\Program Files\R\R-4.5.1\bin\Rscript.exe" reproduce_paper.R
```

### Run Python Script (Python 3.12):
```bash
# Run Agricultural Seedling Experiment demo
python reproduce_paper.py --agri

# Optimize custom design: Tree graph, K=5 groups, N=480, delta=0.40
python reproduce_paper.py --graph tree --k 5 --n 480 --delta 0.40
```

### Verify APK Signatures:
```bash
python verify_apk.py
```

---

## 📖 Citations & References

If you use this software or methodology in your research, please cite both the foundational theoretical paper and the software implementation:

1. **Foundational Theoretical Paper**:
   > Singh, S. P., and Davidov, O. (2026). Max–min experimental designs for comparing pairs of treatments with binary outcomes. *Journal of Statistical Planning and Inference*, 243, 106379. DOI: [10.1016/j.jspi.2025.106379](https://doi.org/10.1016/j.jspi.2025.106379).

2. **Computational Extensions & Software Toolkit**:
   > Lunganlung P G (2026). *MaxMin Design: An Interactive Experimental Optimization and Field Randomization Suite for Pairwise Binary Treatment Comparisons*. Research Suite, ICAR-Indian Agricultural Statistics Research Institute (ICAR-IASRI), New Delhi, India. GitHub: [https://github.com/lunganlungpg/Max-min-Design](https://github.com/lunganlungpg/Max-min-Design).

3. **Related Literature**:
   - Dunnett, C. W. (1955). A multiple comparison procedure for comparing several treatments with a control. *JASA*, 50(272), 1096–1121.
   - Hochberg, Y., and Tamhane, A. C. (1987). *Multiple Comparison Procedures*. John Wiley & Sons.
   - Singh, S. P., and Davidov, O. (2019). On the design of experiments with ordered treatments. *JRSS-B*, 85(5), 881–900.
   - Singh, A., Singh, S. P., and Davidov, O. (2025). Optimal designs for testing pairwise differences: A graph-based game theoretic approach. *Scandinavian Journal of Statistics*, 52(2), 533–571.
