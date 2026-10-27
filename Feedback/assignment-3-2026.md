# Assignment 3 formative feedback

This feedback is organised using the [Computing Bootcamp rubric](https://mulquabio.github.io/MQB/rubrics/Computing_Bootcamp_Rubric.html). It does not award a mark; use it to decide what to revise and check before final submission.

## Criterion 1: Repository organisation & workflow discipline

- Before final submission, **Finish the reproducibility documentation and repository housekeeping.** The required root `README.md` and `code/run_get_TreeHeight.sh` are missing. Commit messages mention `README.txt`, but its contents were not reviewed here. Put the purpose, dependencies, commands and small test examples in the required root README. Your `.gitignore` is empty, while generated `results/TreeHts.csv` and `results/pound_hill_plot_richness.csv` are tracked. Stop tracking generated results and add an appropriate ignore rule, while retaining the scripts that recreate them.

## Criterion 2: Code completeness & functional correctness

- Before final submission, **Complete the tree-height input-to-output route.** In `get_TreeHeight.R`, `commandArgs()` supplies a filename, but the script checks it as though it were an imported table. Read the CSV before checking its columns. The fixed script imports all columns as character, so its numeric checks and calculation also need appropriate conversion of the measurement columns. Test an ordinary file first and inspect the imported column types. Also check the multiple-argument error branch: `EXPECTED_ARGS` and `args` are not defined there. Build the generalised output filename from the input’s filename stem, rather than the full path, and ensure `results/` can be created when absent.

## Criterion 3: Code quality & style

As you revise, keep names descriptive, use comments to explain decisions rather than restating code, and avoid repeating the same calculation in several places.

## Criterion 4: Documentation

Give exact commands in the root `README.md`, together with each script’s input and output files, so that another student could repeat your checks.

## Criterion 5: Version-control practice

- Your Git history contains commits describing particular script and documentation changes, providing a traceable record of your work.

## Criterion 8: Basic error-handling & input validation

- Before final submission, the generalised invalid-input test stopped with a missing-column message. That does **not** establish that it detected the intended invalid measurement: the code suggests it stopped before reading the file. After repairing import, confirm that invalid input produces a relevant message and no result. Review the distance limit of 100 against the released requirements rather than rejecting otherwise valid measurements unnecessarily.

## Criterion 9: Problem-solving approach & method implementation

- Your tree-height functions clearly document the measurements and units, take the angle first and horizontal distance second, and explicitly convert degrees to radians. This is useful evidence from your code, although execution of the calculation was not validated in this run.
- Your Pound Hill source separates identifiers from species counts, checks for invalid counts, calculates richness from species presence and then averages quadrat richness within plots. These are useful stages to explain and check from the original measurements through to the final table.
- Before final submission, **Make the Pound Hill outputs reproducible and check their meaning.** Your code writes `results/pound_hill_plot_richness.csv` and constructs a plot, but contains no explicit PDF-saving step. Ensure it also creates `results/pound_hill_plot_richness.pdf`; compare these exact paths with the filenames actually produced. No newly generated table or PDF was available in the collected output archive, so their contents were not checked—this is not evidence that your table is missing. Trace one quadrat’s species presence through to its plot mean, then visually inspect the PDF’s labels, values and treatment comparison. Explain how the plotted quantity answers your biological question.

## Criterion 10: Learning progression demonstration

Use this feedback as a revision checklist. Make the changes in small, descriptive commits, then add a short README note explaining what you changed and how you checked it. This will make your development from this formative checkpoint visible in the final portfolio.

## Priorities before final submission

- Compare `data/trees.csv` with the supplied original. Its size differed from the reference, so the ordinary fixed/generalised runs and function-interface checks were not launched; this is not a finding that your answers are wrong.
- From the directory containing `code/`, `data/` and the root `README.md`, rerun one ordinary and one invalid case for **each** tree-height program. Test both routes separately.
- Try the taught function example and compare it with an independent direct calculation. Your current row-name comparison checks neither height accuracy nor correspondence of measurement values; also inspect one input row alongside its output.
- Regenerate the Pound Hill outputs without relying on committed results, then inspect the table and PDF.
