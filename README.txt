# Project title and purpose : MQB Computing Bootcamp Theo Jacquin
    Build, manage and learn to use a GitHub repository 

# Project structure : Root directory is CMEE_CourseWork
# Requirements : Languages include Zsh, python, R
# Authors : Theo Jacquin (tj726@ic.ac.uk)
# AI Usage : Google's AI Overview was used to understand and retrieve Zsh commands. 


### Assignment 1: Zsh terminal practical


### Assignment 2: Tree-survey python practical (18.10.26; 11:53)
    ## Objective
This project cleans and validates a Silwood tree-survey CSV. It validates  records, a 
report of rejected ones counts of accepted oak species.

    ## Project structure
- code/clean_silwood_trees.py: cleaning script
- code/test_silwood_trees.py: tests
- results/: generated output files?? # Samraat mention output files, but nothing is outputed

    ## Running overview
Script runs on Python 3. From the repository root (CMEE_CourseWork), run:
    python3 code/clean_silwood_trees.py
The script reads data/silwood_trees_raw.csv and creates these files in results/:
- silwood_trees_clean.csv: accepted records
- silwood_tree_issues.csv: rejected rows +  reasons
- oak_species_counts.csv: accepted oak records counted by species
The results directory is created automatically if it does not exist.

    ## Pseudocode

1. load_records
   - Read the CSV and check its header
   - Return its rows as dictionaries.
2. process_records
   - Start with empty lists for accepted records and rejected-row issues.
   - Process each input row in file order.
   - Pass the row and  id of accepted records to validate_record.
   - If the row is valid, add the cleaned record to the accepted list
   - If not add the source rowand rejection reasons to the issues
   - Sort accepted records by record_id 

3. validate_record
   - Check required values, ranges and genus/species combinations.
   - Convert measurements to numbers and check that they are finite
   - Return the cleaned record if valid; return None and the rejection reasons

4. summarise_oaks
   - Use accepted records only
   - Count records whose genus is Quercus by species
   - Return counts sorted by species.

    ## Authors
Theo Jacquin

    ## AI usage
Google AI Overview was used to understand Zsh commands. It was further used to help 
identify and correct issues in the Python process_records code (which was quite confusing)



### Assignment 3: Tree height R practical (22.10.26; 11:49)
    ## Objective
This project validates the values of a trees.csv file, and applies a height-estimating 
function to each row. It writes the final output as a new .csv in results/TreeHts.csv

    ## Project structure
- code/TreeHeight.R: running script
- data/trees.csv: input data file
- results/TreeHts.csv : output file

   ## Running overview
Script runs on R. From the repository root (CMEE_CourseWork), run:
    Rscript code/TreeHeight.R
The script reads data/trees.csv and creates this file in results/:
- TreeHts.csv
The results directory is created automatically if it does not exist.

   ## Pseudocode


### Pound Hill Practical
This script assesses the validity of the pound hill dataset, then groups data by plot to
calculate mean plot richness. This allows to compare mean richness between treatments. 

    ## Project structure
- code/pound_hill_analysis.R: running script
- data/pound_hill_data.csv: input data file
- data/pound_hill_meta_data.csv : metadata file (read.csv2)
- results/pound_hill_plot_richness.csv: plot-level summary containing Cultivation, Block, Plot and MeanRichness
- results/pound_hill_plot_richness.pdf: figure comparing plot-level mean richness among the three cultivation treatments

   ## Running overview
Script runs on R. From the repository root (CMEE_CourseWork), run:
    Rscript code/pound_hill_analysis.R
The script reads data/pound_hill_data.csv and data/pound_hill_meta_data.csv, creates this file in results/:
- pound_hill_plot_richness.csv
- pound_hill_plot_richness.pdf
The results directory is created automatically if it does not exist.