# Assignment 2 formative feedback

This feedback is organised by the relevant computing bootcamp criteria. Use it to decide what is already working, what you need to investigate, and what to revise before the cumulative submission.

The full criteria are in the [Computing Bootcamp assessment rubric](https://github.com/MulQuaBio/MQB/blob/main/content/rubrics/Computing_Bootcamp_Rubric.md).

## 1. Repository organisation and workflow discipline

- Your `.gitignore`, cleaning script and supplied data files are in the expected locations, and the supplied inputs are unchanged. Add `code/test_silwood_trees.py` under `code/`, as described under Criterion 8.

## 2. Code completeness and functional correctness

- **Resolve the runtime blocker first.** The test run stops before producing the outputs. Separately, output checks found none of the three required CSVs. Treat these as one blocked workflow rather than three independent defects. Start with the first traceback location, check the values passed into that function, fix the error, and rerun before changing later stages.
- Fix the first runtime error and rerun the complete script using the unchanged raw input.
- Once it runs, check that all three CSVs exist and inspect a small sample: follow one accepted record into the cleaned output, one rejected record into the issues output, and check that the oak summary uses the cleaned collection.

## 3. Code quality and style

- Your `main()` function gives the program a clear overall structure by connecting loading, processing, summarising and writing. Keep these stages distinct as you revise; use descriptive names and add short comments where the reason for a validation check or data-cleaning step is not obvious.

## 4. Documentation

- Add a root `README.md` explaining what the cleaner does, how to run the script and tests from the repository root, and which three files it creates. Test the instructions in a newly cloned copy of your repository (a separate folder created with `git clone`): enter that folder and run each README command exactly as written. If something fails, correct the command or add the missing step.

## 5. Version-control practice

- Since the previous formative feedback was added, the saved history contains 7 non-merge commits. Your messages identify setup, a first cleaner version and a fully operable version, which shows progression. Dates and labels such as `Commit 17` are unnecessary because Git already records the date and order.
- Use a concise message such as `Add first TreeHeight implementation`; leave the timestamp and sequence number to Git. Before each commit, run `git diff --staged` and check that it contains one coherent, working change.

## 8. Basic error handling and input validation

- **Add separate, repeatable tests.** `code/test_silwood_trees.py` is absent. This file was added retrospectively, so its absence is not treated as disregard of the original instructions; it is still required for the final cumulative submission. Small tests would help distinguish record-validation problems from loading or writing problems. Start with a valid record, an invalid or boundary case from the metadata, and a check that processing sends each record to the appropriate accepted or rejected collection.

## 9. Problem-solving approach and method implementation

- Your code shows a clear intended workflow: `main()` loads the CSV, passes rows to `process_records()`, which calls `validate_record()`, and receives `(clean_records, issues_rows)`. The cleaned records then feed `summarise_oaks()`, followed by three calls to `write_csv()`. This makes the intended flow visible, although the workflow has not yet run successfully from beginning to end.
- After restoring the required files or fixing the execution error, add an assertion-based test in `code/test_silwood_trees.py` using one valid and one invalid record. Check that `process_records()` places them in the cleaned and issues collections respectively, then pass the cleaned collection to `summarise_oaks()` and check that the invalid record does not contribute. Run the complete cleaner, inspect all three outputs, and briefly explain this flow in your root README.
