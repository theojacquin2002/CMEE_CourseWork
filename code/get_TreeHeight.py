#!/usr/bin/env python3
"""Calculate tree heights from a CSV of species, distances and angles."""

import csv
import math
import sys
from pathlib import Path


REQUIRED_COLUMNS = ["Species", "Distance.m", "Angle.degrees"]


def fail(message: str) -> None:
    """Print an error and exit unsuccessfully."""
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    args = sys.argv[1:]

    if len(args) != 1:
        fail("provide exactly one CSV input path. Usage: "
             "python3 code/get_TreeHeight.py <input.csv>")

    input_path = Path(args[0])

    if input_path.suffix.lower() != ".csv":
        fail("the input file must have a .csv extension.")

    if not input_path.is_file() or not input_path.exists():
        fail(f"input file does not exist: {input_path}")

    if not input_path.open("rb").readable():
        fail(f"input file is not readable: {input_path}")

    output_rows = []

    try:
        with input_path.open(newline="", encoding="utf-8") as source:
            reader = csv.DictReader(source)

            if reader.fieldnames != REQUIRED_COLUMNS:
                found = reader.fieldnames
                fail(
                    f"expected columns {','.join(REQUIRED_COLUMNS)} "
                    f"in that order; found {found}."
                )

            for csv_line, row in enumerate(reader, start=2):
                if None in row:
                    fail(f"{input_path.name}: CSV line {csv_line} has extra fields.")

                species = row.get("Species")
                distance_text = row.get("Distance.m")
                angle_text = row.get("Angle.degrees")

                if species is None or distance_text is None or angle_text is None:
                    fail(f"{input_path.name}: CSV line {csv_line} is missing a field.")

                try:
                    distance = float(distance_text)
                except ValueError:
                    fail(
                        f"{input_path.name}: CSV line {csv_line}, "
                        "'Distance.m' must be numeric."
                    )

                try:
                    angle = float(angle_text)
                except ValueError:
                    fail(
                        f"{input_path.name}: CSV line {csv_line}, "
                        "'Angle.degrees' must be numeric."
                    )

                if not math.isfinite(distance):
                    fail(
                        f"{input_path.name}: CSV line {csv_line}, "
                        "'Distance.m' must be finite."
                    )
                if not math.isfinite(angle):
                    fail(
                        f"{input_path.name}: CSV line {csv_line}, "
                        "'Angle.degrees' must be finite."
                    )

                if not 0 < distance <= 100:
                    fail(
                        f"{input_path.name}: CSV line {csv_line}, "
                        "'Distance.m' must be greater than 0 and at most 100."
                    )
                if not 0 < angle < 90:
                    fail(
                        f"{input_path.name}: CSV line {csv_line}, "
                        "'Angle.degrees' must be greater than 0 and less than 90."
                    )

                height = distance * math.tan(math.radians(angle))

                output_rows.append({
                    "Species": species,
                    "Distance.m": distance_text,
                    "Angle.degrees": angle_text,
                    "height_m": str(height),
                })

    except (OSError, UnicodeError, csv.Error) as error:
        fail(f"could not read '{input_path}': {error}")

    results_dir = Path("results")
    results_dir.mkdir(parents=True, exist_ok=True)

    output_path = results_dir / (
        f"{input_path.stem}_treeheights_python.csv"
    )

    try:
        with output_path.open("w", newline="", encoding="utf-8") as destination:
            writer = csv.DictWriter(
                destination,
                fieldnames=REQUIRED_COLUMNS + ["height_m"],
                lineterminator="\n",
            )
            writer.writeheader()
            writer.writerows(output_rows)
    except OSError as error:
        fail(f"could not write '{output_path}': {error}")

    print(f"Saved {len(output_rows)} tree-height records to {output_path}")


if __name__ == "__main__":
    main()