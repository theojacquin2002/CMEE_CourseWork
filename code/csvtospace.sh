#!/bin/bash
# Author: Theo Jacquin tj726@ic.ac.uk
# Script: csvtospace.sh
# Usage: ./csvtospace.sh <input_file> 
# Desc: substitute the commas in the files with tabs
#       saves the output into a .tsv file
# Arguments: 1-> comma delimited file
# Date: 8 Oct 2015

input_file="$1"

if [["$input_file" != *.csv ]]; then
    echo "Error: Input file must be a .csv file"
    exit 1
fi

if [[ -z "$1" ]]; then
    echo "Error: No input file specified." 
    exit 2
fi

if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
    echo "Error: Input file '$input_file' is missing or unreadable."
    exit 3
fi

output_file="../results/$(basename "$input_file" .csv).txt"

if tr ',' '\t' < "$input_file" >> "$output_file"; then
    echo "Success: Processed $input_file -> $output_file"
else
    echo "Error: Failed to process or write the data." 
    exit 4
fi

