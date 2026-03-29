#!/usr/bin/env bash
set -euo pipefail

#-----------------------------------------------------------------------------------------------------------------------------#

# input, output,  and directories

INPUT="${1:-/mnt/scratch/CS131_jelenag/projects/team08_sec2/group8-amazon-reviews-nlp/data/samples/amz_sample_1000.csv}"
if [[ -z "$INPUT" ]]; then
  echo "Usage: bash run_pa4.sh <INPUT_FILE>"
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: Input file not found: $INPUT"
  exit 1
fi


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

OUT_DIR="$ROOT_DIR/out"
LOG_DIR="$ROOT_DIR/logs"

mkdir -p "$OUT_DIR" "$LOG_DIR"

#-----------------------------------------------------------------------------------------------------------------------------#

# step 1: cleaning dataset

#clean_data() {
# sed -E '
#    s/^"|"$//g;
#    s/","/\t/g;
#    s/[[:space:]]+/ /g;
#    s/^[[:space:]]+|[[:space:]]+$//g;
#    s/([0-9]),([0-9])/\1\2/g;
#    s/\t\t/\tNA\t/g
#  ' "$1"
#}

clean_data() {
  awk 'BEGIN {
    OFS = "\t"
    FPAT = "([^,]*)|(\"([^\"]|\"\")+\")"
  }
  {
    for (i = 1; i <= NF; i++) {
      gsub(/^"|"$/, "", $i)
      gsub(/""/, "\"", $i)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
      if ($i == "") $i = "NA"
    }

    print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
  }' "$1"
}

# saving sample before cleaning it
head -n 5 "$INPUT" > "$OUT_DIR"/sample_before.txt

clean_data "$INPUT" > "$OUT_DIR"/clean.tsv

# saving sample after cleaning it
head -n 5 "$OUT_DIR"/clean.tsv > "$OUT_DIR"/sample_after.txt


normalize_stars() {
 awk -F'\t' 'BEGIN { OFS="\t" }
 NR==1 {
  print $0, "rating_type"
  next
 }
 {
  raw = $5
  cleaned = tolower(raw)

  gsub(/^ +| +$/, "", cleaned)

  if (cleaned == "" || cleaned == "na") {
   stars = "0.00"
   rating_type = "UNRATED"
  } else {
   gsub(/[^0-9.]/, "", cleaned)

   if (cleaned == "") {
    stars = "0.00"
    rating_type = "UNRATED"
   } else {
    stars_num = cleaned + 0
    stars = sprintf("%.2f", stars_num)
    rating_type = (stars_num > 0 ? "RATED" : "UNRATED")
   }
  }

  $5 = stars
  print $0, rating_type
 }' "$1"
}

#-----------------------------------------------------------------------------------------------------------------------------#

# step 2: filtering dataset

filter_data() {
  awk -F'\t' '
  NR==1 || ($5 > 0 && $6 > 0 && $7 > 0)
  ' "$1"
}

normalize_stars "$OUT_DIR"/clean.tsv > "$OUT_DIR"/normalized.tsv
filter_data "$OUT_DIR"/normalized.tsv > "$OUT_DIR"/filtered.tsv

#-----------------------------------------------------------------------------------------------------------------------------#

# step 3: ratios + buckets

compute_metrics() {
  awk -F'\t' '
    NR==1 { next }

    {
      price = $7 + 0
      stars = $5 + 0

      if (price == 0) next

      if (price < 10) bucket="LOW"
      else if (price < 30) bucket="MID"
      else if (price < 100) bucket="HIGH"
      else bucket="PREMIUM"

      count[bucket]++
      sum[bucket] += stars
    }

    END {
      printf "bucket\tcount\tavg_stars\n"
      for (b in count) {
        avg = (count[b] > 0) ? sum[b]/count[b] : 0
        printf "%s\t%d\t%.2f\n", b, count[b], avg
      }
    }
  ' "$1" | sort
}

compute_metrics "$OUT_DIR"/filtered.tsv > "$OUT_DIR"/metrics.tsv

#-----------------------------------------------------------------------------------------------------------------------------#

# step 4: string structure

asin_analysis() {
  awk -F'\t' '
    NR==1 { next }

    {
      prefix = substr($1, 1, 3)
      count[prefix]++
    }

    END {
      printf "asin_prefix\tcount\n"
      for (p in count) {
        printf "%s\t%d\n", p, count[p]
      }
    }
  ' "$1" | sort -k2,2nr
}

asin_analysis "$OUT_DIR"/filtered.tsv > "$OUT_DIR"/asin_summary.tsv

#-----------------------------------------------------------------------------------------------------------------------------#

# step 5: signal discovery

signal_discovery() {
  awk -F'\t' '
BEGIN {
  keywords["lipstick"]; keywords["mascara"]; keywords["blush"]; keywords["eyeliner"];
  keywords["gloss"]; keywords["cream"]; keywords["gel"]; keywords["foundation"];
  keywords["serum"]; keywords["highlighter"];
}
NR==1{next}
{
  stars = $5 + 0
  reviews = $6 + 0
  if(stars >= 4 && reviews >= 20){
    title = tolower($2)
    for(k in keywords){
      if(title ~ k) count[k]++
    }
  }
}
END{
  printf "keyword\tcount\n"
  found=0
  for(k in count){
    printf "%s\t%d\n", k, count[k]
    found=1
  }
  if(found==0) print "no_signals\t0"
}' "$1" | sort -k2,2nr
}

signal_discovery "$OUT_DIR"/filtered.tsv > "$OUT_DIR"/signals.tsv

rating_summary() {
 awk -F'\t' 'BEGIN { OFS="\t" }
 NR==1 { next }

 {
  type = $NF
  count[type]++
  total++
 }

 END {
  print "rating_type", "count", "percentage"
  if ("RATED" in count) {
   pct = (total > 0) ? (count["RATED"]/total)*100 : 0
   printf "RATED\t%d\t%.2f%%\n", count["RATED"], pct
  }
  if ("UNRATED" in count) {
   pct = (total > 0) ? (count["UNRATED"]/total)*100 : 0
   printf "UNRATED\t%d\t%.2f%%\n", count["UNRATED"], pct
  }
 }' "$1"
}

rating_summary "$OUT_DIR"/normalized.tsv > "$OUT_DIR"/rating_summary.tsv
#-----------------------------------------------------------------------------------------------------------------------------#

# output messages / done


echo "pipeline and tasks completed successfully!"
echo "outputs written in: $OUT_DIR"
