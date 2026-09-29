# Applied example

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23035934.svg)](https://doi.org/10.5281/zenodo.23035934)

This repository includes R scripts for the applied example in Mathur et al. (2026), [*Estimating conditional means under missingness-not-at-random with incomplete auxiliary variables*](https://www.researchgate.net/publication/401123077_Estimating_conditional_means_under_missingness-not-at-random_with_incomplete_auxiliary_variables).

## File structure

``` text
applied_example/
├── 01a_prepare_SPHC_data.R
├── 01b_generate_pseudo_data.R
├── 02_main_analysis.Rmd
├── 03_sensitivity_analysis.Rmd
├── 04_model_diagnostics.Rmd
└── 05_validity_check.R
```

## How to run the code

There are two alternative starting points.

### Option 1: Users with authorized access to the SPHC data

Run:

1.  `01a_prepare_SPHC_data.R`
2.  `02_main_analysis.Rmd`
3.  `03_sensitivity_analysis.Rmd`
4.  `04_model_diagnostics.Rmd`
5.  `05_validity_check.R`

### Option 2: Users without access to the SPHC data

Run:

1.  `01b_generate_pseudo_data.R`
2.  `02_main_analysis.Rmd`
3.  `03_sensitivity_analysis.Rmd`
4.  `04_model_diagnostics.Rmd`
5.  `05_validity_check.R`

Do not run both `01a_prepare_SPHC_data.R` and `01b_generate_pseudo_data.R`. They are alternative data-preparation steps.

## Outputs

`02_main_analysis.Rmd` produces:

- `forest_plot.svg` — Figure 4
- `forest_plot_compare.svg` — Figure S4
- `results_all.xlsx` — analysis estimates

## Data availability

The Stockholm Public Health Cohort (SPHC) data used in the applied example are not publicly available because access is subject to [data protection and SPHC data-access requirements](https://www.ces.regionstockholm.se/projekt-och-uppdrag/halsa-stockholm/SPHC-data/).

To facilitate reproducibility, a pseudo-dataset is generated using 01b_generate_pseudo_data.R. Users without authorized access to the SPHC data can run this file to generate example data with the same variable structure required by the subsequent analysis code.
