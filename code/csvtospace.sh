#!/bin/bash
# Author: Theo Jacquin
# Script: csvtospace.sh
# Usage: bash code/csvtospace.sh <input_file.csv>
# Description: Replace commas with spaces and save the output in results/.
# This simple conversion does not parse quoted CSV fields.

if [[ $# -ne 1 ]]; then
    echo "Usage: bash code/csvtospace.sh <input_file.csv>" >&2
    exit 1
fi

input_file="$1"

if [[ "$input_file" != *.csv ]]; then
    echo "Error: input file must have a .csv extension." >&2
    exit 1
fi

if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
    echo "Error: input file does not exist, is not a regular file, or cannot be read: $input_file" >&2
    exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
results_dir="$project_root/results"

if ! mkdir -p "$results_dir"; then
    echo "Error: could not create results directory: $results_dir" >&2
    exit 1
fi

input_filename="${input_file##*/}"
output_file="$results_dir/$input_filename.txt"

if tr ',' ' ' < "$input_file" > "$output_file"; then
    echo "Output saved to $output_file"
else
    echo "Error: conversion failed." >&2
    exit 1
fi