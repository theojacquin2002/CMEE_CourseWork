# Project title and purpose: MQB Computing Bootcamp Theo Jacquin

Build, manage and learn to use a GitHub repository. This project contains UNIX and Bash exercises, Python scripts, and R practicals for tree-survey validation, tree-height calculations and vegetation data analysis.

# Project structure

- `code/`: scripts and practical answers
- `data/`: supplied input files and metadata
- `results/`: generated files, created by scripts when needed
- `sandbox/`: disposable test files

Run commands from the repository root unless a section says otherwise. Keep supplied input data unchanged. Generated results and disposable test files can be recreated and should not be committed.

# Requirements

- Bash and standard UNIX utilities: `awk`, `bc`, `find`, `grep`, `sort`, `tail`, `tr`, `uniq`, `wc` and `xargs`
- ImageMagick’s `convert` command for `tiff2_png.sh`
- Python 3.10 or later; the tree-survey cleaner and tests use the standard library
- R and `Rscript`
- R packages: `reshape2` for `data_wrang.R`, and `tidyverse` for the Pound Hill analysis. The tidyverse includes `dplyr`, `tidyr` and `ggplot2`.

# Authors

Theo Jacquin (tj726@ic.ac.uk)

# AI usage

Google AI Overview was used to understand UNIX and Zsh commands. ChatGPT was used for explanations and code suggestions while debugging Python and R practicals and preparing this README. I reviewed the suggestions and ran checks on my scripts.

## Assignment 1: UNIX and Bash practicals

### `unixPrac1.txt`

This file contains the FASTA exercise answers. Its commands read the supplied files under `data/fasta/` and do not create output files. The input files are:

- `data/fasta/407228326.fasta`
- `data/fasta/407228412.fasta`
- `data/fasta/e_coli.fasta`

Run the commands from `code/`, because their input paths begin with `../data/fasta/`.

```bash
cd code
```

Run each numbered command in `unixPrac1.txt` and compare its output with the explanation. The checks cover newline counts, sequence length, occurrences of `ATGC`, and the ratio `(A + T) / (G + C)`. Sequence length includes ambiguous nucleotide positions; the ratio counts only A, T, G and C. The ratio command uses `bc`.

### `tabtocsv.sh`

Converts one tab-delimited TSV file to comma-separated text. It preserves empty fields, leaves the input unchanged, creates `results/` if needed, and replaces the output on a rerun.

From the repository root, run:

```bash
bash code/tabtocsv.sh data/tab-example.tsv
```

- Input: `data/tab-example.tsv`
- Output: `results/tab-example.tsv.csv`

Check that tabs become commas and consecutive tabs remain consecutive commas. Run the command again and confirm the output is replaced, not appended. Also test disposable files in `sandbox/` with a path containing spaces, a missing argument and a nonexistent input. Invalid inputs should return a non-zero status and print an error.

### `csvtospace.sh`

Replaces commas with spaces in a CSV file. This is a simple character substitution, not a general CSV parser: commas inside quoted fields are also replaced, and spaces in fields cannot be represented unambiguously in the output.

From the repository root, run:

```bash
bash code/csvtospace.sh data/temperatures/1800.csv
```

- Input: `data/temperatures/1800.csv`
- Output: `results/1800.csv.txt`

Check that commas become spaces, repeated commas become repeated spaces, and the input remains unchanged. Run the command again and confirm the output is replaced, not appended. Also test disposable files in `sandbox/` with an empty field, a path containing spaces, a missing argument and a nonexistent input. Invalid inputs should return a non-zero status and print an error.

The supplied converter commands completed successfully and reported outputs under `results/`.

## Assignment 2: Tree-survey Python practical

### Purpose

This practical validates and cleans the synthetic Silwood tree-survey CSV. It writes accepted records, rejected records with their reasons, and a summary of accepted oak species. The supplied raw data is left unchanged.

### Files and usage

Run these commands from the repository root:

```bash
python3 code/test_silwood_trees.py
python3 code/clean_silwood_trees.py
```

- Input: `data/silwood_trees_raw.csv`
- Validation rules: `data/silwood_trees_metadata.md`
- Outputs, created or replaced under `results/`:
  - `silwood_trees_clean.csv`: accepted records, sorted by `record_id`
  - `silwood_tree_issues.csv`: rejected rows, source line numbers and reasons
  - `oak_species_counts.csv`: counts of accepted `Quercus` records by species

The cleaner creates `results/` if it does not exist. These outputs can be regenerated and should not be committed.

### Workflow

1. `load_records` reads the CSV as dictionaries and checks its header.
2. `process_records` processes input rows and collects accepted records and rejected rows.
3. `validate_record` cleans text fields, checks required values and species pairs, and validates measurements and ranges.
4. An identifier is reserved only after its row is accepted. Accepted records are sorted by `record_id`.
5. `summarise_oaks` counts accepted records whose canonical genus is exactly `Quercus`.
6. `main` writes the three output files.

### Formative feedback and checks

After formative feedback, I corrected the validation call and return values so records and rejection reasons flow through the processing function correctly. I added the separate test file.

The tests cover text cleaning, missing and unrecognised values, valid and invalid measurements, range boundaries, duplicate identifiers, multiple rejection reasons, oak summaries, import behaviour and repeatability.

Checks run:

- `python3 code/test_silwood_trees.py` — 16 tests passed.
- `python3 code/clean_silwood_trees.py` — completed and created all three output files.
- I inspected the outputs: 24 accepted records, 12 rejected rows, and oak counts of 4 `petraea` and 4 `robur`.
- Rerunning the cleaner produced identical outputs.

## Assignment 3: Tree-height practicals

### `TreeHeight.R`

This script checks the supplied tree measurements and calculates height in metres using:

`height_m = Distance.m * tan(Angle.degrees * pi / 180)`

From the repository root, run:

```bash
Rscript code/TreeHeight.R
```

- Input: `data/trees.csv`
- Output: `results/TreeHts.csv`

The output retains the input columns in their original order and appends `height_m`. The script creates `results/` if needed and replaces the output on a rerun.

Check that the output has the expected header and 120 data rows. Independently check a height using the formula; for example, a distance of 8 m and an angle of 45 degrees gives 8 m. I also compared the output rows and calculated heights with the input.

### `get_TreeHeight.R`, `get_TreeHeight.py` and `run_get_TreeHeight.sh`

The generalized scripts accept one CSV path with the same three columns as `data/trees.csv`. They check the header and measurements, then write outputs based on the input filename. Two input paths with the same filename stem will produce the same output name for that implementation.

From the repository root, run either implementation alone or the wrapper:

```bash
Rscript code/get_TreeHeight.R data/trees.csv
python3 code/get_TreeHeight.py data/trees.csv
bash code/run_get_TreeHeight.sh
```

- Input: `data/trees.csv`
- R output: `results/trees_treeheights.csv`
- Python output: `results/trees_treeheights_python.csv`

Both scripts create `results/` if needed and replace their output on a rerun. The shell wrapper runs the R and Python scripts in sequence and stops if either fails.

Checks run:

- The generalized R script produced 120 records.
- The Python script produced 120 records.
- The wrapper produced 120 records from each implementation.
- The fixed and generalized R outputs were checked for their headers, row order and calculated heights.
- Disposable invalid-distance inputs were rejected by both R scripts.

After these checks, invalid-input cases for the Python script can be checked with disposable files: no argument, extra arguments, a missing file and an invalid measurement. Invalid inputs should return a non-zero status.

### Formative feedback and checks

After formative feedback, I corrected the generalized R script to read the CSV before checking its columns, convert measurement text to numeric values, validate the required ranges, and build the output name from the input filename stem. The fixed and generalized R scripts were run separately from the repository root.

## Pound Hill practical

### Purpose

This practical checks the Pound Hill vegetation data, calculates species richness for quadrats, and summarizes mean quadrat richness by plot. The figure compares plot-level mean richness among the cultivation treatments.

### Files and usage

From the repository root, run:

```bash
Rscript code/pound_hill_analysis.R
```

- Inputs:
  - `data/pound_hill_data.csv`
  - `data/pound_hill_meta_data.csv`
- Outputs, created or replaced under `results/`:
  - `pound_hill_plot_richness.csv`: plot-level summary containing cultivation, block, plot and mean richness
  - `pound_hill_plot_richness.pdf`: figure comparing plot-level mean richness among cultivation treatments

The script creates `results/` if needed. Check that both files are created. Trace one quadrat’s species presence through to its plot mean, then inspect the PDF’s labels, values and treatment comparison. The plotted quantity is mean quadrat species richness per plot, which allows comparison of richness among treatments.

### Formative feedback and checks

The formative feedback noted that the analysis separates plot identifiers from species counts, checks counts, calculates richness from species presence, and averages quadrat richness within plots. It also identified the need for an explicit PDF-saving step.

The script ran and printed richness values for 59 quadrats and mean richness for 12 plots. For example, March, block `a`, plot `3`, quadrat `Q1` had richness 7; that plot’s mean richness was 6.33. Confirm that the CSV and PDF were created, then inspect the PDF before recording that check as complete.

## Observation-count practical

### Python script and tests

Run from the repository root:

```bash
python3 code/observations_practice.py
python3 code/test_observations_practice.py
```

The Python script reads `data/bootcamp_observations.csv` when run directly. `parse_count` converts non-negative integer text to an integer, returns `None` for empty text, and rejects negative, non-numeric and non-text inputs with `ValueError`.

### R script

Run the ordinary, boundary and invalid files from the repository root:

```bash
Rscript code/observations_practice.R
Rscript code/observations_practice.R data/bootcamp_observations_boundary.csv
Rscript code/observations_practice.R data/bootcamp_observations_invalid.csv
```

The R script reads the ordinary observations by default, or the file supplied as an argument. It creates or replaces `results/observations_known_totals.pdf`.

The ordinary observations file contains sites A and B: A has total 2 and 1 missing count; B has total 0 and no missing counts. The boundary file contains sites C and D: C has an `NA` total and 2 missing counts, while D has total 0 and no missing counts. The invalid file was rejected at CSV line 2 because its count was `-1`.

## Pound Hill data-wrangling practice

Run both scripts from the repository root:

```bash
Rscript code/data_wrang.R
Rscript code/data_wrang_tidy.R
```

Both scripts read `data/pound_hill_data.csv` and `data/pound_hill_meta_data.csv`.

- The `reshape2` version writes `results/pound_hill_long.csv`.
- The `dplyr` and `tidyr` version writes `results/pound_hill_long_tidy.csv`.

Both runs reported 2,419 rows and 6 columns. Their row order differs because the scripts pivot the table differently. Compare records by cultivation, block, plot, quadrat and species before comparing values. Blank species cells represent observed absences and are converted to zero.

## In-class practice scripts

Run these commands from the repository root unless noted otherwise. Disposable files belong in `sandbox/`, and generated results belong in `results/`.

### Bash scripts

| Script | Command and check | Inputs and outputs |
|---|---|---|
| `variables.sh` | Run `bash code/variables.sh demo1 demo2`; enter a string and then two integers when prompted. Check that it reports the values and their sum. | No files |
| `MyExampleScript.sh` | Run `bash code/MyExampleScript.sh` and check the example output. | No files |
| `boilerplate.sh` | Run `bash code/boilerplate.sh` and check that it prints its message. | No files |
| `CheckLabel.sh` | Run `bash code/CheckLabel.sh oak` and `bash code/CheckLabel.sh pine`. Also test no argument and an invalid label; check that invalid cases return a non-zero status. | No files |
| `CountLines.sh` | Run `bash code/CountLines.sh code/unixPrac1.txt` and compare its count with `wc -l`. | Reads the supplied path; prints the line count |
| `ConcatenateTwoFiles.sh` | Run `bash code/ConcatenateTwoFiles.sh sandbox/first.txt sandbox/second.txt sandbox/combined.txt`; inspect the combined output. | Reads two files and creates or replaces the output path |
| `tiff2_png.sh` | This script takes no directory argument and processes `.tif` images in the current directory. From the project root, set the script path, make a disposable folder under `sandbox/`, put a test TIFF there, change into that folder, then run `bash "$script_path"`. Check that a matching PNG appears beside the TIFF. | Reads `*.tif` in the current directory and writes `.png` files there; requires ImageMagick’s `convert` |

### Python scripts

| Script | Command and check | Inputs and outputs |
|---|---|---|
| `loops.py` | Run `python3 code/loops.py`; check the loop values it prints. | No files |
| `cfexercises1.py` | Run the function assertions below. | No files |
| `cfexercises2.py` | Run `python3 code/cfexercises2.py`; check that the hello examples print. | No files |
| `MyExampleScript.py` | Run `python3 code/MyExampleScript.py`; check that it prints the square of 2. | No files |
| `boilerplate.py` | Run `python3 code/boilerplate.py`; check its message. | No files |
| `using_name.py` | Run `python3 code/using_name.py`; check that the module name is `__main__`. | No files |
| `sysargv.py` | Run `python3 code/sysargv.py alpha beta`; check that it reports two arguments, `alpha` and `beta`. | No files |
| `control_flow.py` | Run `python3 code/control_flow.py`; check the example results. | No files |
| `test_control_flow.py` | Run `python3 code/test_control_flow.py`; successful assertions produce no failure output. | No files |
| `observations_practice.py` | Run `python3 code/observations_practice.py`; check the printed example rows. | Reads `data/bootcamp_observations.csv` |
| `test_observations_practice.py` | Run `python3 code/test_observations_practice.py`; successful assertions produce no failure output. | No files |
| `debugme.py` | Run `python3 code/debugme.py`; observe the handled division-by-zero example. | No files |

Test the functions in `cfexercises1.py` from the project root with:

```bash
PYTHONPATH=code python3 -c "from cfexercises1 import foo_1, foo_2, foo_3, foo_4, foo_5, foo_6; assert foo_1(9) == 3; assert foo_2(2, 4) == 4; assert foo_3(3, 1, 2) == [1, 2, 3]; assert foo_4(5) == foo_5(5) == foo_6(5) == 120; print('PASS')"
```

### R scripts

| Script | Command and check | Inputs and outputs |
|---|---|---|
| `basic_io.R` | Run `Rscript code/basic_io.R`; inspect the generated file and its rows. Create `results/` first if it does not exist. | Reads `data/trees.csv`; writes `results/MyData.csv` |
| `boilerplate.R` | Run `Rscript code/boilerplate.R`; check the example function results. | No files |
| `control_flow.R` | Run `Rscript code/control_flow.R`; check the conditional and loop examples. | No files |
| `r_conditionals.R` | Run `Rscript code/r_conditionals.R`; check the example results. | No files |
| `break.R` | Run `Rscript code/break.R`; check that the loop stops when its counter reaches 10. | No files |
| `next.R` | Run `Rscript code/next.R`; check that it prints odd numbers from 1 to 9. | No files |
| `try.R` | Run `Rscript code/try.R`; observe the handled errors and successful results. | No files |
| `browse.R` | Start R from the project root with `R --vanilla`, then run `source("code/browse.R")`. At each browser prompt, inspect the values and continue through the loop; check the resulting growth plot. | Interactive; displays a plot |
| `observations_practice.R` | Run the ordinary, boundary and invalid commands in the Observation-count practical section. | Reads files under `data/`; creates `results/observations_known_totals.pdf` |
| `data_wrang.R` | Run `Rscript code/data_wrang.R`; inspect the long table and its dimensions. | Reads both Pound Hill CSVs; writes `results/pound_hill_long.csv` |
| `data_wrang_tidy.R` | Run `Rscript code/data_wrang_tidy.R`; inspect the long table and its dimensions. | Reads both Pound Hill CSVs; writes `results/pound_hill_long_tidy.csv` |

# Final repository checks

Run commands from the repository root unless a section says otherwise. Keep source code and supplied data under `code/` and `data/`. Do not commit generated results or disposable test files.

Before submission, clone the repository into a new directory and follow the README commands from that copy. Check that the files needed by the scripts are present, the scripts run, and generated outputs can be recreated.