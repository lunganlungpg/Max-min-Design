# ==============================================================================
# maxmindesign: Max-Min Experimental Designs for Comparing Pairs of Treatments
#               with Binary Outcomes
#
# FOUNDATIONAL THEORETICAL PAPER:
# Singh, Satya Prakash (ICAR-IASRI) and Davidov, Ori (University of Haifa) (2026).
# "Max-min experimental designs for comparing pairs of treatments with binary outcomes"
# Journal of Statistical Planning and Inference, Volume 243, Article 106379.
# DOI: 10.1016/j.jspi.2025.106379
#
# RESEARCH INNOVATIONS, METHODOLOGY EXTENSIONS & SOFTWARE IMPLEMENTATION:
# Lunganlung P. G., Agricultural Statistics
# Division of Agricultural Statistics, The Graduate School,
# ICAR-Indian Agricultural Research Institute, New Delhi-110012, India
#
# Install:  remotes::install_github("lunganlungpg/Max-min-Design", subdir = "R-package")
# ==============================================================================

#' Largest-remainder (Hamilton-Hare) rounding of an allocation
#'
#' Converts allocation proportions into integer group sizes that sum exactly
#' to `N`: every `N * xi` is floored and the leftover units go to the groups
#' with the largest fractional parts.
#'
#' @param N Total sample size.
#' @param xi Numeric vector of allocation proportions (sums to 1).
#' @return Integer vector of group sizes, `sum() == N`.
#' @export
#' @examples
#' round_largest_remainder(480, c(4, 1, 1, 1, 1) / 8)
round_largest_remainder <- function(N, xi) {
  K <- length(xi)
  raw <- N * xi
  integers <- floor(raw)
  remainder <- N - sum(integers)
  if (remainder > 0) {
    fractions <- raw - integers
    order_idx <- order(fractions, decreasing = TRUE)
    for (i in seq_len(remainder)) {
      integers[order_idx[i]] <- integers[order_idx[i]] + 1
    }
  }
  return(as.integer(integers))
}

#' Non-centrality parameter of the Wald test
#'
#' Equation 9 of Singh & Davidov (2026). The last group is the reference;
#' weights are inverse Bernoulli variances `n / (theta * (1 - theta))`.
#'
#' @param n Group sizes.
#' @param theta Success probabilities, same length as `n`.
#' @return Non-negative scalar non-centrality parameter.
#' @export
#' @examples
#' calc_ncp(c(92, 100, 94, 98, 96), c(0.413, 0.510, 0.617, 0.561, 0.604))
calc_ncp <- function(n, theta) {
  K <- length(n)
  # Inverse-variance weights
  w <- n / (theta * (1 - theta))
  thK <- theta[K]
  diffs <- theta[1:(K - 1)] - thK
  term1 <- sum(w[1:(K - 1)] * (diffs^2))
  term2 <- sum(w[1:(K - 1)] * diffs)
  sum_w <- sum(w)
  phi <- term1 - (term2^2) / sum_w
  return(max(0, phi))
}

#' Power of the chi-square Wald test
#'
#' @param phi Non-centrality parameter (see [calc_ncp()]).
#' @param df Degrees of freedom (number of groups minus one).
#' @param alpha Significance level.
#' @return Power, a probability.
#' @export
#' @examples
#' calc_power(phi = 12, df = 4)
calc_power <- function(phi, df, alpha = 0.05) {
  crit <- stats::qchisq(1 - alpha, df = df)
  pow <- stats::pchisq(crit, df = df, ncp = phi, lower.tail = FALSE)
  return(pow)
}

#' Minimum total sample size for a target power
#'
#' Searches `N = K, K + 1, ...` and returns the first `N` whose rounded
#' allocation (see [round_largest_remainder()]) reaches `target_power`.
#'
#' @param xi Allocation proportions.
#' @param theta Success probabilities.
#' @param target_power Desired power.
#' @param alpha Significance level.
#' @param max_N Largest `N` to try.
#' @return The smallest such `N`, or `NA` if not reached by `max_N`.
#' @export
#' @examples
#' find_sample_size(c(3, 1, 2, 1, 1) / 8, c(0.413, 0.510, 0.617, 0.561, 0.604))
find_sample_size <- function(xi, theta, target_power = 0.90, alpha = 0.05, max_N = 2000) {
  K <- length(xi)
  df <- K - 1
  crit <- stats::qchisq(1 - alpha, df = df)
  for (N in K:max_N) {
    n <- round_largest_remainder(N, xi)
    phi <- calc_ncp(n, theta)
    pow <- stats::pchisq(crit, df = df, ncp = phi, lower.tail = FALSE)
    if (pow >= target_power) {
      return(N)
    }
  }
  return(NA)
}

#' Max-min allocation for a bipartite comparison graph
#'
#' Theorem 3.3 of Singh & Davidov (2026): for a connected bipartite graph the
#' max-min allocation is proportional to the vertex degrees, `d_i / (2|P|)`.
#'
#' @param degrees Vertex degrees of the comparison graph.
#' @return Allocation proportions summing to 1.
#' @export
#' @examples
#' maxmin_allocation(c(4, 1, 1, 1, 1))   # control vs 4 treatments
maxmin_allocation <- function(degrees) {
  degrees / sum(degrees)   # sum(degrees) = 2 * |P| (handshake lemma)
}

#' Replicate the seedling-emergence case study (Section 4.3)
#'
#' Prints power and sample-size efficiency of the balanced, observed and four
#' max-min designs (Tables 3-4 of the paper).
#'
#' @return Invisibly, a data frame with one row per comparison graph.
#' @export
#' @examples
#' run_seedling_case_study()
run_seedling_case_study <- function() {
  cat("==================================================================\n")
  cat("PART 1: SECTION 4.3 REPLICATION - AGRICULTURAL SEEDLING TRIAL\n")
  cat("==================================================================\n")

  # Seedling Emergence Proportions (Table 2)
  theta_agri <- c(0.413, 0.510, 0.617, 0.561, 0.604)
  names(theta_agri) <- c("Untreated Control", "Hydro-priming", "Bio-priming",
                         "Fungicide dressing", "Integrated treatment")
  N_agri <- 480
  df_agri <- 4

  # Actual and Balanced Allocations
  n_actual <- c(92, 100, 94, 98, 96)
  n_balanced <- round_largest_remainder(N_agri, rep(1/5, 5))

  pow_actual <- calc_power(calc_ncp(n_actual, theta_agri), df_agri)
  pow_balanced <- calc_power(calc_ncp(n_balanced, theta_agri), df_agri)

  cat(sprintf("Observed Trial Allocation Power (pi_AC): %.4f (Paper Table 4: 0.747)\n", pow_actual))
  cat(sprintf("Balanced Allocation Power (pi_BL):       %.4f (Paper Table 4: 0.761)\n\n", pow_balanced))

  # Four graph structures (Figure 2 & Table 3), given by their vertex degrees:
  # (a) Control vs treatments {1-2,1-3,1-4,1-5}
  # (b) Dual reference (bio-priming) {1-3,1-4,1-5,2-3}
  # (c) Cross reference (bio + fungicide) {1-3,1-4,1-5,2-3,2-4}
  # (d) Complete bipartite {1,2} vs {3,4,5}
  graphs <- list("(a)"   = c(4, 1, 1, 1, 1),
                 "(b) \u2605" = c(3, 1, 2, 1, 1),
                 "(c)"   = c(3, 2, 2, 2, 1),
                 "(d)"   = c(3, 3, 2, 2, 2))

  cat("Table 4 Replication: Power and Sample-Size Efficiency for Seed-Emergence\n")
  cat(sprintf("%-10s %-8s %-8s %-8s %-8s %-16s %-16s\n", "Graph", "pi_BL", "pi_AC", "pi_MM", "N_MM", "Red. vs BL", "Red. vs AC"))
  rows <- lapply(names(graphs), function(g) {
    xi <- maxmin_allocation(graphs[[g]])
    pow_mm <- calc_power(calc_ncp(round_largest_remainder(N_agri, xi), theta_agri), df_agri)
    n90 <- find_sample_size(xi, theta_agri, 0.90)
    # 675 and 693 are the 90%-power sample sizes of the balanced / observed designs
    red_bl <- (675 - n90) / 675 * 100
    red_ac <- (693 - n90) / 693 * 100
    cat(sprintf("%-10s %-8.3f %-8.3f %-8.3f %-8d %-16.2f%% %-16.2f%%\n",
                g, pow_balanced, pow_actual, pow_mm, n90, red_bl, red_ac))
    data.frame(graph = g, pi_BL = pow_balanced, pi_AC = pow_actual, pi_MM = pow_mm,
               N_MM = n90, red_vs_BL = red_bl, red_vs_AC = red_ac)
  })
  invisible(do.call(rbind, rows))
}

#' Replicate the simulation benchmark at N = 50 (Section 4.2)
#'
#' Compares balanced and max-min designs for tree and bipartite graphs under
#' least favourable configurations with separations `delta`.
#'
#' @param deltas Minimum separations to evaluate.
#' @param N Total sample size used for the power comparison.
#' @return Invisibly, a data frame with one row per case and delta.
#' @export
#' @examples
#' run_simulation_benchmark(deltas = 0.4)
run_simulation_benchmark <- function(deltas = c(0.30, 0.40, 0.50), N = 50) {
  cat("\n==================================================================\n")
  cat(sprintf("PART 2: SECTION 4.2 REPLICATION - SIMULATION BENCHMARK AT N = %d\n", N))
  cat("==================================================================\n")

  sim_cases <- list(
    list(type = "Tree", k1 = 1, k2 = 4),
    list(type = "Tree", k1 = 1, k2 = 5),
    list(type = "Tree", k1 = 1, k2 = 6),
    list(type = "Bipartite", k1 = 2, k2 = 3),
    list(type = "Bipartite", k1 = 2, k2 = 4),
    list(type = "Bipartite", k1 = 2, k2 = 5)
  )

  cat(sprintf("%-12s %-6s %-6s %-8s %-8s %-12s %-12s %-8s %-8s\n", "Graph", "K1,K2", "delta", "pi_BL", "pi_MM", "Pow. Gain", "NCP. Gain", "N_BL", "N_MM"))
  out <- list()
  for (case in sim_cases) {
    K <- case$k1 + case$k2
    df <- K - 1
    xi_bl <- rep(1/K, K)
    # Max-min: half the units to each side of the bipartition
    xi_mm <- c(rep(0.5 / case$k1, case$k1), rep(0.5 / case$k2, case$k2))
    ncp_gain_formula <- 100 * ((case$k1 - case$k2)^2) / (4 * case$k1 * case$k2)

    for (d in deltas) {
      # Least favourable configuration: the two sides differ by delta around 0.5
      theta_lfc <- c(rep(0.5 - d/2, case$k1), rep(0.5 + d/2, case$k2))
      p_bl <- calc_power(calc_ncp(round_largest_remainder(N, xi_bl), theta_lfc), df)
      p_mm <- calc_power(calc_ncp(round_largest_remainder(N, xi_mm), theta_lfc), df)
      pow_gain <- 100 * (p_mm - p_bl) / p_bl
      n90_bl <- find_sample_size(xi_bl, theta_lfc, 0.90)
      n90_mm <- find_sample_size(xi_mm, theta_lfc, 0.90)

      cat(sprintf("%-12s %d,%-4d %-6.2f %-8.3f %-8.3f %-11.1f%% %-11.1f%% %-8d %-8d\n",
                  case$type, case$k1, case$k2, d, p_bl, p_mm, pow_gain, ncp_gain_formula, n90_bl, n90_mm))
      out[[length(out) + 1]] <- data.frame(
        graph = case$type, k1 = case$k1, k2 = case$k2, delta = d,
        pi_BL = p_bl, pi_MM = p_mm, power_gain_pct = pow_gain,
        ncp_gain_pct = ncp_gain_formula, N_BL = n90_bl, N_MM = n90_mm)
    }
  }
  invisible(do.call(rbind, out))
}
