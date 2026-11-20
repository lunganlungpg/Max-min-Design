# MaxMin Design: Binary Treatment Comparisons
**Complete Toolkit & Android Application for Max-Min Experimental Designs**

Developed for **Lunganlung P G**, Ph.D. Scholar (Agricultural Statistics), Roll No: 13173  
**ICAR - Indian Agricultural Statistics Research Institute (ICAR-IASRI)**, Library Avenue, Pusa, New Delhi – 110012.  
Based on research by **Singh, S. P., and Davidov, O. (2026)**, *Journal of Statistical Planning and Inference*, 243, 106379.

---

## 📦 Project Deliverables

| Deliverable | File | Description |
| :--- | :--- | :--- |
| **Android APK** | [MaxMinDesign.apk](file:///c:/Users/lungh/OneDrive%20-%20Helwan%20university(Social%20Services)/Desktop/g_anti/app1/MaxMinDesign.apk) | **Version 1.2.0** — Signed production APK with offline mathematical engine, interactive graph matrix, 2D sensitivity heatmap, field randomizer, adaptive icons, and PDF/CSV export |
| **R Analysis Script** | [maxmin_designs.R](file:///c:/Users/lungh/OneDrive%20-%20Helwan%20university(Social%20Services)/Desktop/g_anti/app1/maxmin_designs.R) | Executable R 4.5.1 / RStudio script reproducing Section 4.2 & 4.3 |
| **Python CLI Tool** | [maxmin_designs.py](file:///c:/Users/lungh/OneDrive%20-%20Helwan%20university(Social%20Services)/Desktop/g_anti/app1/maxmin_designs.py) | Standalone Python 3.12 command-line optimizer & simulator |
| **APK Verification** | [verify_apk.py](file:///c:/Users/lungh/OneDrive%20-%20Helwan%20university(Social%20Services)/Desktop/g_anti/app1/verify_apk.py) | Automated test suite validating APK integrity and cryptographic signatures |
| **Build Pipeline** | [build_apk.py](file:///c:/Users/lungh/OneDrive%20-%20Helwan%20university(Social%20Services)/Desktop/g_anti/app1/build_apk.py) | Automated Android build toolchain using AAPT2, javac, D8, zipalign & apksigner |

---

## 📱 Android Application Features (MaxMinDesign.apk)

1. **Interactive Comparison Graph Optimizer**:
   - Built-in models: Tree (Dunnett Control vs Treatments), Path (Adjacent Doses), Complete Bipartite ($K_1, K_2$), Complete Graph.
   - **Interactive Custom Graph Matrix**: Toggle comparisons between any treatment pair $(i, j)$ with real-time connectivity checking.
   - **Degree Allocation Rule**: $\xi_i = \frac{d_i}{2|P|}$.
   - **Hamilton-Hare Largest-Remainder Rounding**: Exact integer group sample sizes summing to $N$.
   - **Poisson-Mixture Chi-Squared Inversion**: High-precision power calculation and sample size determination for target power (e.g. 90%).

2. **Agricultural Seedling-Emergence Case Study (Section 4.3)**:
   - Full replication of the 5-treatment seed trial ($N = 480$ seeds).
   - Interactive selector for comparison graphs (a), (b), (c), and (d) from Figure 2.
   - Interactive bar chart reproducing Figure 3 with 90% power reference line.
   - Explanation of why Graph (b) achieves **30.88% seed savings** by concentrating degree on Untreated Control and Bio-priming.

3. **Simulation Benchmark Explorer (Section 4.2)**:
   - Interactive reproduction of Table 1A & Table 1B across Tree $(1,4), (1,5), (1,6)$ and Bipartite $(2,3), (2,4), (2,5)$.
   - Visual bar chart reproducing Figure 1 at $\delta = 0.40, N = 50$.
   - Geometric NCP gain display: $100 \times \frac{(K_1 - K_2)^2}{4 K_1 K_2} \%$.

4. **Native Android Capabilities**:
   - **Save to Downloads**: Saves `.csv` data tables and `.txt` trial protocols to the Android device's Downloads directory.
   - **Print / PDF Generator**: Triggers the Android system PrintManager to print or save the protocol as a PDF document.
   - **Android Share Sheet**: Share protocols directly via WhatsApp, Gmail, or messaging apps.
   - **Adaptive App Icons**: Supports circular, rounded, and squircle icons on Android 8 through Android 15.

---

## 💻 Running the R and Python Tools

### Run R Script (RStudio / R 4.5.1):
```bash
"C:\Program Files\R\R-4.5.1\bin\Rscript.exe" maxmin_designs.R
```

### Run Python Script (Python 3.12):
```bash
# Run Agricultural Seedling Experiment demo
python maxmin_designs.py --agri

# Optimize custom design: Tree graph, K=5 groups, N=480, delta=0.40
python maxmin_designs.py --graph tree --k 5 --n 480 --delta 0.40
```

### Verify APK:
```bash
python verify_apk.py
```
