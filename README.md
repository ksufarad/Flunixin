# Integration of Food Animal Residue Avoidance Databank empirical methods with population-based interactive physiologically-based pharmacokinetic platform

## Contents

- [Overview](#overview)
- [Repo Contents](#repo-contents)
- [Installation Guide](#installation-guide)
- [Instructions for Use](#instructions-for-use)
- [Reproducibility](#Reproducibility)

# Overview

This iPBPK framework represents the application of PBPK modeling in the field of food safety. It is based on a PBPK model for flunixin in swine and cattle. This framework can be applied to develop new models for other drugs and environmental chemicals in other species, as well as to translate published models to user-friendly interfaces. The developed model itself can help predict a WDI after extralabel use in cattle and swine, and can also be extrapolated to other food animal production classes or exposure routes.  

# Repo Contents

- [BM](./BM): Model codes in Berkeley Madonna. The codes are also available in the supplementary materials
- [iPBPK](./iPBPK): The interactive physiologically-based pharmacokinetic interface. It is also available through https://pengpbpk.shinyapps.io/Flunixin/


# Installation Guide

## Installing Berkeley Madonna version 8.3.18 on Windows 7 

The version can be found on the download webpage https://berkeley-madonna.myshopify.com/pages/download, or using the link http://www.berkeleymadonna.com/downloads/bm8_3_18cwin.exe directly. The installation should take no longer than 1 minute.

Berkeley Madonna is also available for Macintosh OS.

## Installing R version 3.5.1 on Windows 7

The latest version of R can be installed by downloading from https://cran.r-project.org/bin/windows/base/ and following the instructions through https://cran.r-project.org/bin/windows/base/README.R-3.5.1.

The installation should finish within about 1 minute.

## Package dependencies in R

Users should install the following packages prior to run the population model:

```
install.packages(c('shiny', 'shinydashboard', 'shinyjs', 'ggplot2', 'truncnorm', 'EnvStats', 'knitr', 'dplyr', 'rmarkdown'))
```
which will install in about 30 seconds on a regular computer.

The package 'mrgsolve' can be obtained from https://github.com/metrumresearchgroup/mrgsolve. The installation of 'mrgsolve' should strictly follow the instruction on https://github.com/metrumresearchgroup/mrgsolve/wiki/mrgsolve-Installation. As this package has other prerequisites packages, the installation may take up to 20 minutes.

## Package Versions in R

```
mrgsolve: 0.8.12
shiny: 1.1.0
shinydashboard: 0.7.1
shinyjs: 1.0
ggplot2: 3.1.0
truncnorm: 1.0-8
EnvStats: 2.3.1
knitr: 1.20
dplyr: 1.2.1
rmarkdown: 1.10
```

# Instructions for Use

## model codes in Berkeley Madonna
Please refer to the word document including in the 'BM' folder for the instructions and expecting results.

## model codes in iPBPK folder
Please refer to the instructions in the 'iPBPK' folder or the tutorial at https://pengpbpk.shinyapps.io/Flunixin/

# Reproducibility
The figures can be reproduced using the provided codes.
