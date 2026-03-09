#!/bin/bash


# Usage:
# /scripts/run_sprint3.sh <dataset_path>

# Example:
# /scripts/run_sprint3.sh data/samples/amz_sample_1000.csv

--------------------------------------------------------------

DATASET=$1

mkdir -p out/evidence

echo "starting script 3..." | tee out/run_sprint3.log

echo "extracting rating and price columns..." | tee -a out/run_sprint3.log

# Extract rating (col5) and price (col7)
awk -F',' '{print $5 "," $7}' "$DATASET" > out/evidence/price_rating.csv 2> out/errors.log

echo "trend dataset created: out/evidence/price_rating.csv" | tee -a out/run_sprint3.log

echo "sprint 3 run complete." | tee -a out/run_sprint3.log
