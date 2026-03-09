#!/bin/bash

# ----------------------------------------------------------------------------------------------------------
## creating price and boughtinlastmonth table ##

# Usage:
# /scripts/run_sprint3.sh <dataset_path>

# Example:
# /scripts/run_sprint3.sh data/samples/amz_sample_1000.csv

# ---------------------------------------------------------------------------------------------------------

DATASET=$1

mkdir -p out/evidence

echo "starting script 3..." | tee out/run_sprint3.log

echo "extracting rating and price columns..." | tee -a out/run_sprint3.log

# Extract rating (col5) and price (col7)
awk -F',' '{print $5 "," $7}' "$DATASET" > out/evidence/price_rating.csv 2> out/errors.log

echo "trend dataset created: out/evidence/price_rating.csv" | tee -a out/run_sprint3.log

echo "price and bought in last month table created." | tee -a out/run_sprint3.log

# ---------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------

## creating correlation matrix between 3 variables ##

# Usage:
# /scripts/run_sprint3.sh

# Input:
# out/three_variable.txt (3 columns: X Y Z)

# Output:
# out/evidence/correlation_matrix.txt

# ---------------------------------------------------------------------------------------------------------

INPUT_FILE="out/three_variables.txt"
OUTPUT_FILE="out/evidence/correlation_matrix.txt"

# Ensure output directory exists
mkdir -p out

# Skip the header and compute correlation using awk
awk -F',' -v out="$OUTPUT_FILE" '
NR>1 {
    i=NR-1
    x[i]=$1; y[i]=$2; z[i]=$3
}
END {
    n=i

    for(i=1;i<=n;i++){
        sumx+=x[i]; sumy+=y[i]; sumz+=z[i]
    }

    meanx=sumx/n; meany=sumy/n; meanz=sumz/n

    for(i=1;i<=n;i++){
        cx=x[i]-meanx; cy=y[i]-meany; cz=z[i]-meanz
        sumxx+=cx*cx; sumyy+=cy*cy; sumzz+=cz*cz
        sumxy+=cx*cy; sumxz+=cx*cz; sumyz+=cy*cz
    }

    r_xy=sumxy/sqrt(sumxx*sumyy)
    r_xz=sumxz/sqrt(sumxx*sumzz)
    r_yz=sumyz/sqrt(sumyy*sumzz)

    print "       boughtInLastMonth   stars    reviews" > out
    printf "boughtInLastMonth  %7.3f  %7.3f  %7.3f\n", 1, r_xy, r_xz >> out
    printf "stars              %7.3f  %7.3f  %7.3f\n", r_xy, 1, r_yz >> out
    printf "reviews            %7.3f  %7.3f  %7.3f\n", r_xz, r_yz, 1 >> out
}
' "$INPUT_FILE"
echo "correlation matrix saved to $OUTPUT_FILE"
