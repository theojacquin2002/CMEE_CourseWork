import csv


def load_observations(path):
    """Load observation rows as dictionaries."""
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def parse_count(count_text):
    """Convert non-negative count text to an integer; return None if missing."""
    if not isinstance(count_text, str):
        raise ValueError("count must be text")

    if count_text == "":
        return None

    try:
        count = int(count_text)
    except ValueError as error:
        raise ValueError("count must be an integer") from error

    if count < 0:
        raise ValueError("count cannot be negative")

    return count


if __name__ == "__main__":
    rows = load_observations("data/bootcamp_observations.csv")
    print(rows[0])
    print(rows[2])