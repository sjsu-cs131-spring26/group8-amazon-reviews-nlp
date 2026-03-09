#!/usr/bin/env python3
import argparse
import csv
import os
from collections import Counter

MISSING_TOKENS = {"", "na", "n/a", "null", "none", "nan"}

def norm(s: str) -> str:
    return (s or "").strip()

def is_missing(s: str) -> bool:
    return norm(s).lower() in MISSING_TOKENS

def safe_int(s: str):
    try:
        return int(float(norm(s)))
    except Exception:
        return None

def safe_float(s: str):
    try:
        return float(norm(s))
    except Exception:
        return None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input_path")
    ap.add_argument("--delim", default=",")
    ap.add_argument("--out_clean_path", default="out/clean/cleaned_amz_ca.csv")
    ap.add_argument("--evidence_dir", default="out/evidence")
    args = ap.parse_args()

    os.makedirs(os.path.dirname(args.out_clean_path), exist_ok=True)
    os.makedirs(args.evidence_dir, exist_ok=True)

    total = 0
    kept = 0
    drop = Counter()
    seen_asin = set()

    dup_samples = []
    invalid_samples = []

    # Column names for this Kaggle file (common ones)
    # We’ll auto-detect and require at least these:
    # asin, categoryName, stars, reviews, boughtInLastMonth
    with open(args.input_path, "r", newline="", encoding="utf-8", errors="replace") as f_in:
        reader = csv.DictReader(f_in, delimiter=args.delim)
        if not reader.fieldnames:
            raise SystemExit("ERROR: no header found")

        required = ["asin", "categoryName", "stars", "reviews", "boughtInLastMonth"]
        missing_cols = [c for c in required if c not in reader.fieldnames]
        if missing_cols:
            raise SystemExit(
                f"ERROR: missing required columns: {missing_cols}\n"
                f"Found columns: {reader.fieldnames}"
            )

        with open(args.out_clean_path, "w", newline="", encoding="utf-8") as f_out:
            writer = csv.DictWriter(f_out, fieldnames=reader.fieldnames, delimiter=args.delim)
            writer.writeheader()

            for row in reader:
                total += 1
                asin = norm(row.get("asin"))
                cat = norm(row.get("categoryName"))
                stars = safe_float(row.get("stars"))
                reviews = safe_int(row.get("reviews"))
                bought = safe_int(row.get("boughtInLastMonth"))

                if is_missing(asin):
                    drop["missing_asin"] += 1
                    if len(invalid_samples) < 20:
                        invalid_samples.append(("missing_asin", row))
                    continue

                if asin in seen_asin:
                    drop["duplicate_asin"] += 1
                    if len(dup_samples) < 20:
                        dup_samples.append(row)
                    continue

                if is_missing(cat):
                    drop["missing_categoryName"] += 1
                    if len(invalid_samples) < 20:
                        invalid_samples.append(("missing_categoryName", row))
                    continue

                # numeric sanity checks
                if stars is None or stars < 0 or stars > 5:
                    drop["invalid_stars"] += 1
                    if len(invalid_samples) < 20:
                        invalid_samples.append(("invalid_stars", row))
                    continue

                if reviews is None or reviews < 0:
                    drop["invalid_reviews"] += 1
                    if len(invalid_samples) < 20:
                        invalid_samples.append(("invalid_reviews", row))
                    continue

                if bought is None or bought < 0:
                    drop["invalid_boughtInLastMonth"] += 1
                    if len(invalid_samples) < 20:
                        invalid_samples.append(("invalid_boughtInLastMonth", row))
                    continue

                seen_asin.add(asin)
                writer.writerow(row)
                kept += 1

    # Evidence artifacts
    with open(os.path.join(args.evidence_dir, "cleaning_summary.txt"), "w", encoding="utf-8") as f:
        f.write("Cleaning summary\n")
        f.write(f"input_path={args.input_path}\n")
        f.write(f"output_clean_path={args.out_clean_path}\n")
        f.write(f"total_rows={total}\n")
        f.write(f"kept_rows={kept}\n")
        f.write(f"dropped_rows={total-kept}\n\n")
        f.write("drop_reasons:\n")
        for k, v in drop.most_common():
            f.write(f"{k}={v}\n")

    with open(os.path.join(args.evidence_dir, "duplicates_sample.txt"), "w", encoding="utf-8") as f:
        f.write("Sample duplicate rows (by asin)\n")
        for r in dup_samples:
            f.write(str(r) + "\n")

    with open(os.path.join(args.evidence_dir, "invalid_rows_sample.txt"), "w", encoding="utf-8") as f:
        f.write("Sample invalid rows (reason, row)\n")
        for reason, r in invalid_samples:
            f.write(f"{reason}\t{r}\n")

    with open(os.path.join(args.evidence_dir, "clean_dataset_path.txt"), "w", encoding="utf-8") as f:
        f.write(args.out_clean_path + "\n")

if __name__ == "__main__":
    main()
