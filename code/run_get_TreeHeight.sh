#!/usr/bin/env bash

# Run both tree-height implementations from the project root.
Rscript code/get_TreeHeight.R data/trees.csv
python3 code/get_TreeHeight.py data/trees.csv