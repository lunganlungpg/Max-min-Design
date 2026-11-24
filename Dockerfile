# Container image published to GitHub Packages as
#   ghcr.io/lunganlungpg/max-min-design
#
# Bundles the Python CLI and the R package `maxmindesign`:
#   docker run --rm ghcr.io/lunganlungpg/max-min-design                                   # Section 4.3 demo
#   docker run --rm ghcr.io/lunganlungpg/max-min-design maxmin-designs --graph path --k 6 --n 300
#   docker run --rm ghcr.io/lunganlungpg/max-min-design Rscript maxmin_designs.R          # R replication
#   docker run --rm ghcr.io/lunganlungpg/max-min-design Rscript -e 'maxmindesign::find_sample_size(c(4,1,1,1,1)/8, c(.3,.7,.7,.7,.7))'

# rocker/r-ver = Ubuntu + pinned R.
FROM rocker/r-ver:4.4.2

LABEL org.opencontainers.image.title="max-min-design" \
      org.opencontainers.image.description="Max-min experimental designs for binary treatment comparisons (Python + R)" \
      org.opencontainers.image.licenses="MIT"

# Python runtime (venv is used because Ubuntu blocks system-wide pip installs).
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/max-min-design
COPY . .

# 1) Python CLI `maxmin-designs` (no third-party dependencies)
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir .
ENV PATH="/opt/venv/bin:${PATH}"

# 2) R package `maxmindesign` (depends only on base R)
RUN R CMD INSTALL R-package

# Fail the build early if either package cannot be loaded.
RUN maxmin-designs --graph tree --k 4 --n 100 > /dev/null \
 && Rscript -e 'library(maxmindesign)'

CMD ["maxmin-designs", "--agri"]
