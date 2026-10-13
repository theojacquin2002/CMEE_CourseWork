#!/bin/bash
# Author: Theo Jacquin tj726@ic.ac.uk
# Script: tabtocsv.sh
# Usage: ./tabtocsv.sh <input_file> 
# Desc: substitute the tabs in the files with commas
#       saves the output into a .csv file
# Arguments: 1-> tab delimited file
# Date: 8 Oct 2015

input_file="$1"

if [["$input_file" != *.tsv ]]; then
    echo "Error: Input file must be a .tsv file"
    exit 1
fi

output_file="../results/$(basename "$input_file").csv"

if tr '\t' ',' < "$input_file" > "$output_file"; then
    echo "Output saved to $output_file"
else
    echo "Error: conversion failed." 
    exit 1
fi
