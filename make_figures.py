#!/usr/bin/env python3
"""Draw the README figures for the seed-emergence case study (Section 4.3).

Usage:  python make_figures.py      (needs matplotlib; writes SVG files to figures/)
All numbers come from the power engine in maxmin_designs.py.
"""
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

import maxmin_designs as mm

OUT = Path(__file__).resolve().parent / "figures"
OUT.mkdir(exist_ok=True)

SURFACE, INK, INK2, MUTED, GRID, AXIS = "#fcfcfb", "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7"
BLUE, ORANGE, AQUA, YELLOW = "#2a78d6", "#eb6834", "#1baf7a", "#eda100"
GREY = "#a9a8a2"

plt.rcParams.update({
    "font.family": ["Segoe UI", "DejaVu Sans", "sans-serif"], "font.size": 10,
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
    "axes.edgecolor": AXIS, "axes.labelcolor": INK2, "text.color": INK,
    "xtick.color": MUTED, "ytick.color": MUTED, "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.6, "axes.axisbelow": True,
    "svg.fonttype": "path",
})

THETA = [0.413, 0.510, 0.617, 0.561, 0.604]          # observed emergence rates, Section 4.3
TREATMENTS = ["Untreated\ncontrol", "Hydro-\npriming", "Bio-\npriming", "Fungicide\ndressing", "Integrated\ntreatment"]
N = 480
GRAPHS = {                                            # name: (vertex degrees, number of edges |P|)
    "(a) Control vs 4 treatments": ([4, 1, 1, 1, 1], 4),
    "(b) Dual reference (bio-priming)": ([3, 1, 2, 1, 1], 4),
    "(c) Cross reference (bio + fungicide)": ([3, 2, 2, 2, 1], 5),
    "(d) Complete bipartite {1,2}×{3,4,5}": ([3, 3, 2, 2, 2], 6),
}
N90_BALANCED, N90_ACTUAL = 675, 693                  # reference values used by maxmin_designs.run_agri_demo


def xi_of(degs, edges):
    return [d / (2.0 * edges) for d in degs]


def power_at(n_total, xi):
    return mm.calc_power(mm.calc_ncp(mm.round_largest_remainder(n_total, xi), THETA), len(xi) - 1)


def title(fig, main, sub):
    fig.text(0.02, 0.97, main, fontsize=12.5, fontweight="bold", va="top", color=INK)
    fig.text(0.02, 0.905, sub, fontsize=9.5, va="top", color=INK2)


# ---------------------------------------------------------------- Figure 1: seeds needed for 90% power
rows = [("Balanced (equal groups)", N90_BALANCED, GREY), ("Actual trial allocation", N90_ACTUAL, GREY)]
for name, (degs, edges) in GRAPHS.items():
    rows.append((f"Max–min, graph {name}", mm.find_sample_size(xi_of(degs, edges), THETA, 0.90),
                 BLUE if name.startswith("(b)") else "#86b6ef"))

fig, ax = plt.subplots(figsize=(7.6, 3.9))
fig.subplots_adjust(left=0.40, right=0.95, top=0.78, bottom=0.14)
y = list(range(len(rows)))[::-1]
for yi, (name, n90, color) in zip(y, rows):
    ax.barh(yi, n90, 0.62, color=color)
    saving = "" if color == GREY else f"   (−{100 * (N90_ACTUAL - n90) / N90_ACTUAL:.1f}%)"
    ax.text(n90 + 8, yi, f"{n90}{saving}", va="center", fontsize=8.8, color=INK if color == BLUE else INK2,
            fontweight="bold" if color == BLUE else "normal")
ax.set_yticks(y, [r[0] for r in rows], fontsize=9, color=INK2)
ax.tick_params(axis="y", length=0)
ax.grid(axis="y", visible=False)
ax.set_xlim(0, 860)
ax.set_xlabel("Seeds needed for 90% power  (fewer is better; % is saving vs the actual trial)")
title(fig, "The best comparison graph needs 214 fewer seeds",
      "Five seed treatments, α = 0.05, emergence rates from the Section 4.3 trial")
fig.savefig(OUT / "seeds_for_90_power.svg")
plt.close(fig)

# ---------------------------------------------------------------- Figure 2: power against total seeds
Ns = list(range(150, 901, 10))
series = [
    ("Balanced (equal groups)", [0.2] * 5, GREY, (0, (4, 3))),
    ("Max–min, graph (a)", xi_of(*GRAPHS["(a) Control vs 4 treatments"]), AQUA, "-"),
    ("Max–min, graph (b)", xi_of(*GRAPHS["(b) Dual reference (bio-priming)"]), BLUE, "-"),
]
fig, ax = plt.subplots(figsize=(7.6, 3.9))
fig.subplots_adjust(left=0.1, right=0.96, top=0.72, bottom=0.14)
for name, xi, color, ls in series[::-1]:
    ax.plot(Ns, [power_at(n, xi) for n in Ns], color=color, lw=2, ls=ls, label=name)
handles, labels = ax.get_legend_handles_labels()
fig.legend(handles[::-1], labels[::-1], loc="upper left", bbox_to_anchor=(0.02, 0.86), ncol=3, frameon=False,
           fontsize=8.8)
ax.axhline(0.9, color=MUTED, lw=1, ls=(0, (2, 3)))
ax.text(155, 0.91, "90% target power", fontsize=8.5, color=MUTED, va="bottom")
ax.axvline(N, color=AXIS, lw=1)
ax.text(N + 8, 0.08, f"N = {N} seeds\n(the trial's size)", fontsize=8.5, color=INK2)
for name, xi, color, _ in series[::2]:
    p480 = power_at(N, xi)
    ax.scatter([N], [p480], s=55, color=color, edgecolor=SURFACE, lw=1.5, zorder=4)
    ax.text(N - 10, p480 + (0.03 if color == BLUE else -0.06), f"{p480:.2f}", ha="right", fontsize=8.8,
            color=INK if color == BLUE else INK2)
ax.set_xlim(150, 900)
ax.set_ylim(0, 1)
ax.set_yticks([0, 0.2, 0.4, 0.6, 0.8, 1.0], ["0", "20%", "40%", "60%", "80%", "100%"])
ax.set_xlabel("Total seeds N")
ax.set_ylabel("Power of the Wald test")
title(fig, "Same seeds, more power",
      "With 480 seeds, the max–min design for graph (b) reaches 90% power; equal groups reach 76%")
fig.savefig(OUT / "power_curves.svg")
plt.close(fig)

# ---------------------------------------------------------------- Figure 3: how the 480 seeds are split
bal = mm.round_largest_remainder(N, [0.2] * 5)
mmb = mm.round_largest_remainder(N, xi_of(*GRAPHS["(b) Dual reference (bio-priming)"]))
fig, ax = plt.subplots(figsize=(7.6, 3.7))
fig.subplots_adjust(left=0.09, right=0.97, top=0.72, bottom=0.2)
x, w = range(5), 0.38
ax.bar([i - w / 2 - 0.01 for i in x], bal, w, color=GREY, label="Balanced (equal groups)")
ax.bar([i + w / 2 + 0.01 for i in x], mmb, w, color=BLUE, label="Max–min, graph (b)")
for i in x:
    ax.text(i - w / 2, bal[i] + 4, str(bal[i]), ha="center", fontsize=8.5, color=INK2)
    ax.text(i + w / 2, mmb[i] + 4, str(mmb[i]), ha="center", fontsize=8.5, color=INK)
ax.set_xticks(list(x), TREATMENTS, fontsize=9, color=INK2)
ax.tick_params(axis="x", length=0)
ax.grid(axis="x", visible=False)
ax.set_ylim(0, 210)
ax.set_ylabel("Seeds per treatment")
fig.legend(loc="upper left", bbox_to_anchor=(0.02, 0.86), ncol=2, frameon=False, fontsize=8.8)
title(fig, "Where the max–min design puts the seeds",
      "N = 480; allocation ∝ vertex degree (Theorem 3.3), rounded exactly by largest remainder")
fig.savefig(OUT / "allocation_480.svg")
plt.close(fig)

print("wrote", *sorted(p.name for p in OUT.glob("*.svg")))
