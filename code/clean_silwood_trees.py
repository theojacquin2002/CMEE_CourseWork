#!/usr/bin/env python3
"""Validate and clean the synthetic Silwood tree survey."""

from __future__ import annotations
import csv
from pathlib import Path
from typing import Iterable


PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"
RESULTS_DIR = PROJECT_ROOT / "results"

INPUT_FIELDS = [
    "record_id",
    "location",
    "genus",
    "species",
    "distance_m",
    "angle_degrees",
]
ISSUE_FIELDS = ["source_row", "record_id", "reasons"]
OAK_COUNT_FIELDS = ["species", "count"]


def load_records(path: Path = INPUT_PATH) -> list[dict[str, str]]:
    """Read the survey and check its column names."""
    with path.open(newline="", encoding="utf-8") as source: # do not understand this
        reader = csv.DictReader(source)
        if reader.fieldnames != INPUT_FIELDS:
            raise ValueError(
                f"Expected columns {INPUT_FIELDS}, found {reader.fieldnames}"
            )
        return list(reader) # yes lsit reader


def validate_record(
    row: dict[str, str],
    source_row: int,
    accepted_ids: set[str],
) -> tuple[dict[str, str] | None, list[str]]:
    """Clean one record, or return the reasons it cannot be used."""

    reasons: list[str] = []

    # making a list of what the variables are
    record_id = (row.get("record_id") or "").strip() # row.get() grabs the proper value
    
    location = (row.get("location") or "").strip()
    genus = (row.get("genus") or "").strip()
    species = (row.get("species") or "").strip()
    locations = {
        "silwood bottom": "Silwood Bottom",
        "nash's field": "Nash's Field",
        "manor house": "Manor House",
        "reactor wood": "Reactor Wood",
    }
    genera = {

        "quercus": "Quercus",
        "acer": "Acer",
        "betula": "Betula",
        "fagus": "Fagus",
        "fraxinus": "Fraxinus",
    }
    species_names = {

        "robur": "robur",
        "petraea": "petraea",
        
        "pseudoplatanus": "pseudoplatanus",
        "pendula": "pendula",
        "sylvatica": "sylvatica",
        "excelsior": "excelsior",
    }
    valid_pairs = {
        ("Quercus", "robur"),
        ("Quercus", "petraea"),
        ("Acer", "pseudoplatanus"),
        ("Betula", "pendula"),
        ("Fagus", "sylvatica"),
        
        
        ("Fraxinus", "excelsior"),
    }

    # casefold apparently cleans strings better than .lower()
    clean_location = locations.get(location.casefold())
    clean_genus = genera.get(genus.casefold())
    ####bb.
    clean_species = species_names.get(species.casefold())

    valid_record_id = (
        len(record_id) == 5 # total length would be 5
        and record_id.startswith("ST") # starts with ST
        and record_id[2:].isdigit() # the last 3 characters are digits (starts from 0, so 2 is 3)
    )

    if not record_id: # missing and incorrect record_id is not treated the same
        reasons.append("missing record_id")
    elif not valid_record_id:
        
        reasons.append("invalid record_id")


    if valid_record_id and record_id in accepted_ids: # accepted_ids is given at beg of function
        reasons.append("duplicate record_id")

    # copy paste for all variables:
    if not location:
        reasons.append("missing location")
    elif clean_location is None:

        reasons.append("invalid location")
    if not genus:
        reasons.append("missing genus")
    elif clean_genus is None:


        reasons.append("invalid genus")

    if not species:
        reasons.append("missing species")
    elif clean_species is None:
        reasons.append("invalid species")

    if ( # to invalidate pairs
        clean_genus is not None # check that genus is correct
        and clean_species is not None # check species

        and (clean_genus, clean_species) not in valid_pairs # genus species pair not valid
    ):
        reasons.append("invalid genus/species combination")


    # create dictionary to store the numeric values of distance and angle
    numbers: dict[str, float] = {}

    for field in ("distance_m", "angle_degrees"): # apparently i can loop over multiple objects like this
        raw_value = (row.get(field) or "").strip()
        if not raw_value:
            reasons.append(f"missing {field}") # if not value
            continue
        try:
            value = float(raw_value)
        except ValueError:

            reasons.append(f"invalid {field}") # if the value in field is not floatable
            continue
        if value == float("inf") or value == float("-inf"): # check for Infinites
            reasons.append(f"infinite value for {field}")
            continue

        numbers[field] = value

        if field == "distance_m" and not (0 < value <= 100): # easily check range
            reasons.append("distance_m out of range")

        elif field == "angle_degrees" and not (0 < value < 90): # easily check range of value
            reasons.append("angle_degrees out of range")

    if reasons:
        return None, reasons
    return {
        "record_id": record_id,
        "location": clean_location,
        "genus": clean_genus,
        "species": clean_species,
        "distance_m": str(numbers["distance_m"]),
        "angle_degrees": str(numbers["angle_degrees"]),
    }


def process_records(
    rows: Iterable[dict[str, str]],
) -> tuple[list[dict[str, str]], list[dict[str, str]]]: # dont understand what this tuple does/means
    """Sort records into accepted rows and issue reports."""
    clean_records = []
    issues_rows = []
    accepted_ids = set()

    for source_row in rows:
        record, reasons = validate_record(source_row, accepted_ids) # validate_record returns a tuple of (record, reasons)
    if record is None:
        issues_rows.append(
            {
                "source_row": str(source_row), # autocompleted by helper
                "record_id": source_row.get("record_id", ""),
                "reasons": "; ".join(reasons),
            }
        )
    else:
        clean_records.append(record)
        accepted_ids.add(record["record_id"])
    return clean_records, issues_rows

def summarise_oaks(clean_records: Iterable[dict[str, str]]) -> list[dict[str, str]]: #  Iterable
    """Count accepted oak records by species."""
    counts = {}

    for record in clean_records:
        if record["genus"] == "Quercus":
            species = record["species"]
            counts[species] = counts.get(species, 0) + 1

    return [
        {"species": species, "count": str(counts[species])} # counts(species)
        for species in sorted(counts) # sorted() returns a sorted list of the keys in counts = species names
    ]


def write_csv(
    path: Path,
    fieldnames: list[str],
    rows: Iterable[dict[str, str]],
) -> None:
    """Write rows to a CSV file, replacing an older copy."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.DictWriter(destination, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    """Clean the survey and write the three result files."""
    clean_records, issues = process_records(load_records())
    oak_counts = summarise_oaks(clean_records)

    write_csv(
        RESULTS_DIR / "silwood_trees_clean.csv",
        INPUT_FIELDS,
        clean_records,
    )
    write_csv(
        RESULTS_DIR / "silwood_tree_issues.csv",
        ISSUE_FIELDS,
        issues,
    )
    write_csv(
        RESULTS_DIR / "oak_species_counts.csv",
        OAK_COUNT_FIELDS,
        oak_counts,
    )


if __name__ == "__main__":
    main()
