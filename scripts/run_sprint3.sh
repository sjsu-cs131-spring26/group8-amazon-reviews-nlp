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

INPUT_FILE="out/three_variable.txt"
OUTPUT_FILE="out/evidence/correlation_matrix.txt"

# Ensure output directory exists
mkdir -p out

# Skip the header and compute correlation using awk
awk -F',' '
NR>1 {
    x[NR-1]=$1; y[NR-1]=$2; z[NR-1]=$3; n=NR-1
}
END {
    # compute means
    sumx=sumy=sumz=0
    for(i=1;i<=n;i++){
        sumx+=x[i]; sumy+=y[i]; sumz+=z[i]
    }
    meanx=sumx/n; meany=sumy/n; meanz=sumz/n

    # compute centered sums
    sumxx=sumyy=sumzz=0
    sumxy=sumxz=sumyz=0
    for(i=1;i<=n;i++){
        cx=x[i]-meanx; cy=y[i]-meany; cz=z[i]-meanz
        sumxx+=cx*cx; sumyy+=cy*cy; sumzz+=cz*cz
        sumxy+=cx*cy; sumxz+=cx*cz; sumyz+=cy*cz
    }

    # Pearson r -- statistical correlation
    r_xy=sumxy/sqrt(sumxx*sumyy)
    r_xz=sumxz/sqrt(sumxx*sumzz)
    r_yz=sumyz/sqrt(sumyy*sumzz)

    # print matrix to file
    print "       boughtInLastMonth   stars    reviews" > "'"$OUTPUT_FILE"'"
    printf "boughtInLastMonth  %7.3f  %7.3f  %7.3f\n", 1, r_xy, r_xz >> "'"$OUTPUT_FILE"'"
    printf "stars              %7.3f  %7.3f  %7.3f\n", r_xy, 1, r_yz >> "'"$OUTPUT_FILE"'"
    printf "reviews            %7.3f  %7.3f  %7.3f\n", r_xz, r_yz, 1 >> "'"$OUTPUT_FILE"'"
}
' "$INPUT_FILE"

echo "Correlation matrix saved to $OUTPUT_FILE"
