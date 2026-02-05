# Stereo-XCR-seq-LUAD
# stereo-xcr-seq

## Description

**Stereo-XCR-seq** is an innovative approach designed to overcome the lack of tools for **in situ single-cell T/BCR (XCR) sequencing**. This efficient strategy retrieves and sequences **TCR** and **BCR** from Stereo-seq cDNA libraries at subcellular resolution. Stereo-XCR-seq provides unbiased full-length XCR reads alongside **spatial transcriptomics**, enabling comprehensive insights into immune repertoire and spatial gene expression.

## Repository Structure

This repository is organized to facilitate data integration, immune repertoire construction, and spatial transcriptomic analysis. Main directories include:

---

### 1. `meta_build&preprocess`

- **Purpose:**  
  Contains all scripts for processing sequencing fastq files, running **mixcr** on raw data, constructing meta files based on mixcr results, and integrating meta files into spatial transcriptomics AnnData objects.
- **Contents:**  
  - Batch preprocessing shell scripts and pipeline automation.
  - Python and bash tools for building and managing meta files.
  - Code for mapping XCR sequences into spatial transcriptomic coordinates.

---

### 2. `Main_Figure`

- **Purpose:**  
  Contains the scripts used to generate the **main figures** in the corresponding publication.
- **Contents:**  
  - Data analysis code and visualization scripts for all main manuscript figures.
  - Reproducible notebooks for key biological findings.

---

### 3. `sup_Figure`

- **Purpose:**  
  Contains the scripts for generating **supplementary figures**.
- **Contents:**  
  - Analytical code and visualization utilities for all supplementary or extended data figures.
  - Notebooks and scripts for in-depth, secondary, or additional analysis.
