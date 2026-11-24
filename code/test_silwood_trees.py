#!/usr/bin/env python3
"""Assertion-based tests for clean_silwood_trees.py."""

import csv
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

import clean_silwood_trees as cleaner


CODE_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = CODE_DIR.parent
RAW_INPUT = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"

OUTPUT_NAMES = [
    "silwood_trees_clean.csv",
    "silwood_tree_issues.csv",
    "oak_species_counts.csv",
]


def valid_row(**changes: str) -> dict[str, str]:
    """Return a valid sample record, with any requested fields changed."""
    row = {
        "record_id": "ST001",
        "location": "Silwood Bottom",
        "genus": "Quercus",
        "species": "robur",
        "distance_m": "25.5",
        "angle_degrees": "35",
    }
    row.update(changes)
    return row


class TestValidateRecord(unittest.TestCase):
    def test_cleans_whitespace_and_letter_case(self) -> None:
        row = valid_row(
            record_id=" ST012 ",
            location="  nASH'S fIELD ",
            genus=" qUeRCuS ",
            species=" ROBUR ",
        )

        record, reasons = cleaner.validate_record(row, 2, set())

        self.assertEqual(reasons, [])
        self.assertEqual(
            record,
            {
                "record_id": "ST012",
                "location": "Nash's Field",
                "genus": "Quercus",
                "species": "robur",
                "distance_m": "25.5",
                "angle_degrees": "35.0",
            },
        )

    def test_reports_missing_fields_in_required_order(self) -> None:
        row = valid_row(
            record_id="",
            location="",
            genus="",
            species="",
            distance_m="",
            angle_degrees="",
        )

        record, reasons = cleaner.validate_record(row, 2, set())

        self.assertIsNone(record)
        self.assertEqual(
            reasons,
            [
                "missing record_id",
                "missing location",
                "missing genus",
                "missing species",
                "missing distance_m",
                "missing angle_degrees",
            ],
        )

    def test_rejects_unrecognised_text(self) -> None:
        row = valid_row(location="Unknown place", genus="Unknown tree")

        record, reasons = cleaner.validate_record(row, 2, set())

        self.assertIsNone(record)
        self.assertEqual(reasons, ["invalid location", "invalid genus"])

    def test_rejects_unrecognised_species_and_invalid_taxon_pair(self) -> None:
        unknown_species = valid_row(species="unknown")
        record, reasons = cleaner.validate_record(unknown_species, 2, set())
        self.assertIsNone(record)
        self.assertEqual(reasons, ["invalid species"])

        invalid_pair = valid_row(genus="Quercus", species="excelsior")
        record, reasons = cleaner.validate_record(invalid_pair, 2, set())
        self.assertIsNone(record)
        self.assertEqual(reasons, ["invalid genus/species combination"])

    def test_accepts_measurement_boundaries_that_are_in_range(self) -> None:
        row = valid_row(distance_m="100", angle_degrees="0.001")

        record, reasons = cleaner.validate_record(row, 2, set())

        self.assertEqual(reasons, [])
        self.assertIsNotNone(record)

    def test_rejects_unconvertible_and_non_finite_measurements(self) -> None:
        for field, value in [
            ("distance_m", "twelve"),
            ("distance_m", "nan"),
            ("distance_m", "inf"),
            ("angle_degrees", "ninety"),
            ("angle_degrees", "-inf"),
            ("angle_degrees", "nan"),
        ]:
            with self.subTest(field=field, value=value):
                record, reasons = cleaner.validate_record(
                    valid_row(**{field: value}), 2, set()
                )
                self.assertIsNone(record)
                self.assertEqual(reasons, [f"invalid {field}"])

    def test_rejects_measurements_outside_allowed_ranges(self) -> None:
        for field, value in [
            ("distance_m", "0"),
            ("distance_m", "100.1"),
            ("angle_degrees", "0"),
            ("angle_degrees", "90"),
        ]:
            with self.subTest(field=field, value=value):
                record, reasons = cleaner.validate_record(
                    valid_row(**{field: value}), 2, set()
                )
                self.assertIsNone(record)
                self.assertEqual(reasons, [f"{field} out of range"])

    def test_collects_multiple_reasons_in_metadata_order(self) -> None:
        row = valid_row(
            record_id="",
            location="Unknown place",
            genus="Quercus",
            species="excelsior",
            distance_m="nan",
            angle_degrees="90",
        )

        record, reasons = cleaner.validate_record(row, 2, set())

        self.assertIsNone(record)
        self.assertEqual(
            reasons,
            [
                "missing record_id",
                "invalid location",
                "invalid genus/species combination",
                "invalid distance_m",
                "angle_degrees out of range",
            ],
        )


class TestProcessingAndOakSummary(unittest.TestCase):
    def test_duplicate_id_is_rejected_after_first_accepted_record(self) -> None:
        clean, issues = cleaner.process_records(
            [valid_row(), valid_row(location="Manor House")]
        )

        self.assertEqual(len(clean), 1)
        self.assertEqual(issues[0]["source_row"], "3")
        self.assertEqual(issues[0]["record_id"], "ST001")
        self.assertEqual(issues[0]["reasons"], "duplicate record_id")

    def test_invalid_row_does_not_reserve_its_id(self) -> None:
        invalid_first = valid_row(location="Unknown place")
        valid_second = valid_row()

        clean, issues = cleaner.process_records([invalid_first, valid_second])

        self.assertEqual([row["record_id"] for row in clean], ["ST001"])
        self.assertEqual(issues[0]["reasons"], "invalid location")

    def test_issue_output_uses_trimmed_record_id(self) -> None:
        invalid = valid_row(record_id=" ST007 ", location="Unknown place")

        clean, issues = cleaner.process_records([invalid])

        self.assertEqual(clean, [])
        self.assertEqual(issues[0]["record_id"], "ST007")

    def test_clean_records_are_sorted_by_record_id(self) -> None:
        clean, _ = cleaner.process_records(
            [valid_row(record_id="ST009"), valid_row(record_id="ST002")]
        )

        self.assertEqual(
            [row["record_id"] for row in clean],
            ["ST002", "ST009"],
        )

    def test_oak_summary_requires_exact_canonical_genus(self) -> None:
        records = [
            {"genus": "Quercus", "species": "robur"},
            {"genus": "Quercus", "species": "petraea"},
            {"genus": "NotQuercus", "species": "robur"},
            {"genus": "quercus", "species": "robur"},
        ]

        self.assertEqual(
            cleaner.summarise_oaks(records),
            [
                {"species": "petraea", "count": "1"},
                {"species": "robur", "count": "1"},
            ],
        )

    def test_oak_summary_is_empty_when_there_are_no_oaks(self) -> None:
        records = [{"genus": "Acer", "species": "pseudoplatanus"}]

        self.assertEqual(cleaner.summarise_oaks(records), [])


class TestProgramBehaviour(unittest.TestCase):
    def test_import_does_not_run_program_or_create_results(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            project = Path(temporary_directory)
            code_dir = project / "code"
            code_dir.mkdir()

            shutil.copy2(
                CODE_DIR / "clean_silwood_trees.py",
                code_dir / "clean_silwood_trees.py",
            )

            result = subprocess.run(
                [sys.executable, "-c", "import clean_silwood_trees"],
                cwd=code_dir,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "")
            self.assertEqual(result.stderr, "")
            self.assertFalse((project / "results").exists())

    def test_running_twice_replaces_outputs_with_identical_results(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            project = Path(temporary_directory)
            code_dir = project / "code"
            data_dir = project / "data"
            code_dir.mkdir()
            data_dir.mkdir()

            shutil.copy2(
                CODE_DIR / "clean_silwood_trees.py",
                code_dir / "clean_silwood_trees.py",
            )
            shutil.copy2(RAW_INPUT, data_dir / "silwood_trees_raw.csv")
            original_input = (data_dir / "silwood_trees_raw.csv").read_bytes()

            command = [
                sys.executable,
                str(code_dir / "clean_silwood_trees.py"),
            ]

            subprocess.run(command, cwd=project, check=True)

            results_dir = project / "results"
            self.assertTrue(results_dir.is_dir())
            first_outputs = {
                name: (results_dir / name).read_bytes()
                for name in OUTPUT_NAMES
            }

            with (results_dir / "silwood_trees_clean.csv").open(
                newline="", encoding="utf-8"
            ) as source:
                clean_rows = list(csv.DictReader(source))
            with (results_dir / "silwood_tree_issues.csv").open(
                newline="", encoding="utf-8"
            ) as source:
                issue_rows = list(csv.DictReader(source))
            with (results_dir / "oak_species_counts.csv").open(
                newline="", encoding="utf-8"
            ) as source:
                oak_rows = list(csv.DictReader(source))

            self.assertEqual(
                [row["record_id"] for row in clean_rows],
                sorted(row["record_id"] for row in clean_rows),
            )
            self.assertEqual(
                [int(row["source_row"]) for row in issue_rows],
                sorted(int(row["source_row"]) for row in issue_rows),
            )
            self.assertEqual(
                oak_rows,
                cleaner.summarise_oaks(clean_rows),
            )

            subprocess.run(command, cwd=project, check=True)

            second_outputs = {
                name: (results_dir / name).read_bytes()
                for name in OUTPUT_NAMES
            }

            self.assertEqual(first_outputs, second_outputs)
            self.assertEqual(
                (data_dir / "silwood_trees_raw.csv").read_bytes(),
                original_input,
            )


if __name__ == "__main__":
    unittest.main(verbosity=2)