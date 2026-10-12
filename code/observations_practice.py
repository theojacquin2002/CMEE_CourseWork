import csv


def load_observations(path):
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))

def parse_count(count_text):
    isinstance(count_text, str)
    if count_text == "":
        return None
    if count_text != "":
        int(count_text)


    if int(count_text) == int < 0:
        raise ValueError("Count cannot be negative")
    if int(count_text) == int:
        return int
    if count_text == str:
        raise ValueError("Count cannot be a string")



print(parse_count(22))

if __name__ == "__main__":
    rows = load_observations("data/bootcamp_observations.csv")
    print(rows[0])
    print(rows[2])

