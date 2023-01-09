---
title: "software installation"
---

*Note*: some people use the [Anaconda](https://www.anaconda.com/) stack to manage their installations of Python (and other languages). It is slightly notorious for not playing nicely with other software; if you use it I'm happy for you but you may have to find Anaconda-specific instructions for installing all the bits and pieces below.

## Git

* https://git-scm.com/downloads/
* install Git (https://happygitwithr.com/ has instructions designed around R/RStudio; 
* https://www.jcchouinard.com/install-git-in-vscode/ has VSCode-centred instructions

## Github

* get a Github user name (if you don't have one already)
* create a repository called `stat790`
* add me as a collaborator (Settings > Collaborators > enter `bbolker`)
* https://code.visualstudio.com/docs/sourcecontrol/overview
* e-mail me or send me a message on Piazza telling me your GH user name

## R

R is a domain-specific language for statistics and data science

If you already have R installed, please make sure that you have upgraded to the latest version!

* Download links: https://mirror.csclub.uwaterloo.ca/CRAN/ or https://cloud.r-project.org/
* in the course of the term you may need compilation tools for building R code that includes compiled (C/Fortran) code
   * [MacOS tools](https://mac.r-project.org/tools/)
   * [Windows tools](https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html)
   * if you use Linux you are likely to have most of these tools already, but see [here](https://cran.r-project.org/bin/linux/) (and go to the subdirectory appropriate for your distribution); you may also want to use [r2u](https://github.com/eddelbuettel/r2u#r2u-cran-as-ubuntu-binaries) to simplify and speed up package installation


## Julia

Julia is a domain-specific language for high-performance computing and data analysis.

* https://julialang.org/downloads/

## Quarto

[Quarto](https://quarto.org/) is a scientific publishing/reporting system for integrating code and output in a document or notebook.

* https://quarto.org/docs/get-started/

## VSCode

[Visual Studio Code](https://code.visualstudio.com/) (VSCode) is an integrated development environment (IDE). While it primarily targets software development rather than data analysis, it handles multiple languages better than RStudio (see below).

* https://code.visualstudio.com/download
* (`sudo apt install code -y` on recent Debian-based linux)

## R and Julia support

* open VSCode, go to *Extensions*, install extensions for:
   * Julia
   * R (install `languageserver` package in R)
   * (because I'm weird) Awesome Emacs 

When in doubt, install the top/most-downloaded extension available for a given task

## TeX 

[TeX](https://en.wikipedia.org/wiki/TeX) is an ancient (first released in the 1970s) typesetting/document creation system that is still standard in mathematics and many technical fields

   - [install TinyTeX for quarto](https://quarto.org/docs/output-formats/pdf-engine.html)


## extras

* recommended `radian` R console (also need Python installed!) `pip install radian`; update settings. See https://code.visualstudio.com/docs/languages/r
* spellchecker?
