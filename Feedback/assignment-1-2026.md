# Assignment 1 feedback - Theo Jacquin

**Formative feedback | Rubric 2026.2**

There are useful explanations of null-separated filenames and individual motif occurrences, and the commit messages identify actual stages of development. Q1, Q2 and Q4 matched the independent checks. The next revision needs to concentrate on the unfinished calculations and converter behaviour rather than presentation.

Start with the shell tests: the [[ expressions need the required spacing. Then correct csvtospace.sh, which currently replaces commas with tabs, appends to the output and changes the required basename. The task is comma-to-space conversion, with the specified output replaced on a repeated run. Neither script should assume the results directory already exists.

Q3 ends in plain wc and prints several statistics rather than selecting sequence length. Q5 stops at base frequencies without calculating the requested ratio. Those outputs were left for review, not accepted as completed numerical answers. Finish each calculation and explain what its final output means. Also explain why the two numbered FASTA files have one fewer newline than visually displayed lines.

The committed temperature files differ from the released references, so their dependent checks were not run. Compare them with the supplied originals before drawing conclusions from local conversion results. Populate the empty own TSV, put the documentation in the required README.md rather than README.txt, and add exact commands, small output tests, dependencies and any help used. Ignore generated results and keep using descriptive commits.

---

## Project structure

Relevant tracked layout (simplified; missing required paths are marked):

```text
README.md  [missing]
.gitignore
code/  unixPrac1.txt, tabtocsv.sh, csvtospace.sh
data/fasta/  3 required files present
data/temperatures/  4 required files present
data/tab-example.tsv [empty]
results/  no files tracked; generated on run
sandbox/  12 files tracked
Also: README.txt
Input-content differences: data/temperatures/1800.csv, data/temperatures/1801.csv, data/temperatures/1802.csv, data/temperatures/1803.csv
```

The assessed code and required input filenames are present, but the root guide is README.txt rather than the required README.md, and the own TSV is empty. Sandbox contains classwork, test data and a tracked compiled Python cache. The temperature filenames are present, but their contents differ from the released references.

Provide README.md, populate the own TSV and resolve the supplied-data differences. Move durable classroom source out of sandbox, keeping only disposable experiments there locally. Untrack the compiled cache; an ignore rule does not remove files already in Git. Add a results rule without hiding required input data.

**Assessed snapshot:** `dc922fb6c1c1aadc628a1320d5d49894e28c91b8`
