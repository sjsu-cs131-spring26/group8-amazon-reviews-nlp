#!/usr/bin/env bash
set -euo pipefail

# Sprint 3 Entry Script
# Usage:
#   ./scripts/run_sprint3.sh <DATASET_PATH> <DELIM>
#
# Example (CSV):
#   ./scripts/run_sprint3.sh data/amz_ca_total_products_data_processed.csv ","

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <DATASET_PATH> <DELIM>" >&2
  exit 1
fi

DATASET_PATH="$1"
DELIM="$2"

OUT_DIR="out"
EVID_DIR="${OUT_DIR}/evidence"
CLEAN_DIR="${OUT_DIR}/clean"
LOG="${OUT_DIR}/run_sprint3.log"
ERR="${OUT_DIR}/errors.log"

mkdir -p "${EVID_DIR}" "${CLEAN_DIR}"
: > "${LOG}"
: > "${ERR}"

# Log stdout to run log (tee) and stderr to errors log
exec > >(tee -a "${LOG}") 2> >(tee -a "${ERR}" >&2)

echo "Sprint 3 run started"
date
echo "Dataset: ${DATASET_PATH}"
echo "Delimiter: '${DELIM}'"
echo

if [[ ! -f "${DATASET_PATH}" ]]; then
  echo "ERROR: dataset not found at: ${DATASET_PATH}" >&2
  exit 2
fi

echo "File size"
ls -lh "${DATASET_PATH}" | tee "${EVID_DIR}/file_size.txt"
echo

echo "Header preview"
head -n 3 "${DATASET_PATH}" | tee "${EVID_DIR}/header_preview.txt"
echo

echo "Row count (raw)"
wc -l "${DATASET_PATH}" | tee "${EVID_DIR}/row_count_raw.txt"
echo

echo "Cleaning dataset -> out/clean/cleaned_amz_ca.csv"
python3 scripts/clean_dataset.py "${DATASET_PATH}" \
  --delim "${DELIM}" \
  --out_clean_path "${CLEAN_DIR}/cleaned_amz_ca.csv" \
  --evidence_dir "${EVID_DIR}"
echo

echo "Row count (cleaned)"
wc -l "${CLEAN_DIR}/cleaned_amz_ca.csv" | tee "${EVID_DIR}/row_count_cleaned.txt"
echo

echo "Generating Top-N lists from cleaned dataset"
python3 scripts/topn_products.py "${CLEAN_DIR}/cleaned_amz_ca.csv" \
  --delim "${DELIM}" \
  --evidence_dir "${EVID_DIR}"
echo

echo "Done"
date
