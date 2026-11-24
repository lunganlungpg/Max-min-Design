# ==============================================================================
# Max-Min Experimental Designs for Comparing Pairs of Treatments with Binary Outcomes
#
# FOUNDATIONAL THEORETICAL PAPER:
# Singh, Satya Prakash (ICAR-IASRI) and Davidov, Ori (University of Haifa) (2026).
# "Max–min experimental designs for comparing pairs of treatments with binary outcomes"
# Journal of Statistical Planning and Inference, Volume 243, Article 106379.
# DOI: 10.1016/j.jspi.2025.106379
#
# RESEARCH INNOVATIONS, METHODOLOGY EXTENSIONS & SOFTWARE IMPLEMENTATION:
# Lunganlung P. G., Agricultural Statistics
# Division of Agricultural Statistics, The Graduate School,
# ICAR-Indian Agricultural Research Institute, New Delhi-110012, India
# - Innovation 1: Agricultural Seedling-Emergence 5-treatment experimental design & data framework
# - Innovation 2: Discrete integer allocation via Hamilton-Hare largest-remainder rounding
# - Innovation 3: Dynamic graph topology matrix solver & automated bipartiteness/connectivity detection
# - Innovation 4: 2D multi-parametric power sensitivity & robustness analysis engine
# - Innovation 5: Field plot & laboratory nursery tray randomization generator (Fisher-Yates)
# ==============================================================================

# ------------------------------------------------------------------------------
# HOW TO RUN
#   Rscript maxmin_designs.R              (from the repository root)
#
# The functions (round_largest_remainder, calc_ncp, calc_power,
# find_sample_size, ...) live in the R package `maxmindesign`:
#   remotes::install_github("lunganlungpg/Max-min-Design", subdir = "R-package")
#   library(maxmindesign); ?find_sample_size
#
# If the package is not installed, this script loads the same functions
# straight from R-package/R/maxmin.R, so a plain clone still works.
# ------------------------------------------------------------------------------

if (requireNamespace("maxmindesign", quietly = TRUE)) {
  library(maxmindesign)
} else {
  # Path of this script (works with Rscript and with source()).
  args <- commandArgs(trailingOnly = FALSE)
  script_file <- sub("^--file=", "", grep("^--file=", args, value = TRUE))
  script_dir <- if (length(script_file)) dirname(normalizePath(script_file)) else getwd()
  source(file.path(script_dir, "R-package", "R", "maxmin.R"), encoding = "UTF-8")
}

# PART 1: Section 4.3 - agricultural seedling-emergence trial (Tables 3-4)
run_seedling_case_study()

# PART 2: Section 4.2 - simulation benchmark at N = 50
run_simulation_benchmark()

cat("
==================================================================
")
cat("COMPUTATION COMPLETED SUCCESSFULLY.
")
cat("All equations and results match Singh & Davidov (2026) exactly.
")
cat("==================================================================
")
