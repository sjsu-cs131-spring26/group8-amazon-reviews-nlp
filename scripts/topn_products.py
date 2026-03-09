#!/usr/bin/env python3
import argparse
import csv
import os
from collections import defaultdict

def norm(s: str) -> str:
    return (s or "").strip()

def safe_int(s: str):
    try:
        return int(float(norm(s)))
    except Exception:
        return 0

def safe_float(s: str):
    try:
        return float(norm(s))
    except Exception:
        return 0.0

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("clean_path")
    ap.add_argument("--delim", default=",")
    ap.add_argument("--evidence_dir", default="out/evidence")
    ap.add_argument("--top_k_categories", type=int, default=10)
    ap.add_argument("--top_k_products", type=int, default=20)
    args = ap.parse_args()

    os.makedirs(args.evidence_dir, exist_ok=True)

    rows = []
    cat_purchases = defaultdict(int)

    with open(args.clean_path, "r", newline="", encoding="utf-8", errors="replace") as f:
        reader = csv.DictReader(f, delimiter=args.delim)
        for r in reader:
            asin = norm(r.get("asin"))
            cat = norm(r.get("categoryName"))
            stars = safe_float(r.get("stars"))
            reviews = safe_int(r.get("reviews"))
            bought = safe_int(r.get("boughtInLastMonth"))

            rows.append((asin, cat, stars, reviews, bought))
            cat_purchases[cat] += bought

    # 1) Top categories by purchases
    top_cats = sorted(cat_purchases.items(), key=lambda x: x[1], reverse=True)[: args.top_k_categories]
    top_cat_set = {c for c, _ in top_cats}

    with open(os.path.join(args.evidence_dir, "top_categories_by_purchases.txt"), "w", encoding="utf-8") as f:
        f.write("rank,categoryName,total_boughtInLastMonth\n")
        for i, (c, p) in enumerate(top_cats, start=1):
            f.write(f"{i},{c},{p}\n")

    # Sorting rule: boughtInLastMonth desc, then stars desc, then reviews desc
    def sort_key(x):
        asin, cat, stars, reviews, bought = x
        return (bought, stars, reviews)

    # 2) Top products overall
    top_overall = sorted(rows, key=sort_key, reverse=True)[: args.top_k_products]
    with open(os.path.join(args.evidence_dir, "top_products_overall.txt"), "w", encoding="utf-8") as f:
        f.write("rank,asin,categoryName,boughtInLastMonth,stars,reviews\n")
        for i, (asin, cat, stars, reviews, bought) in enumerate(top_overall, start=1):
            f.write(f"{i},{asin},{cat},{bought},{stars},{reviews}\n")

    # 3) Top products within top categories
    filtered = [r for r in rows if r[1] in top_cat_set]
    top_in_topcats = sorted(filtered, key=sort_key, reverse=True)[: args.top_k_products]
    with open(os.path.join(args.evidence_dir, "top_products_in_top_categories.txt"), "w", encoding="utf-8") as f:
        f.write("rank,asin,categoryName,boughtInLastMonth,stars,reviews\n")
        for i, (asin, cat, stars, reviews, bought) in enumerate(top_in_topcats, start=1):
            f.write(f"{i},{asin},{cat},{bought},{stars},{reviews}\n")

if __name__ == "__main__":
    main()
