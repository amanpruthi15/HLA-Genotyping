#!/bin/bash

set -euo pipefail

DIR="${1%/}"
DATE=$(date +%F)

RAW="$DIR/combined_results_raw.tsv"
SORTED="$DIR/combined_results_sorted_table.tsv"
FINAL="$DIR/${DATE}_hla_allele-call_Table.tsv"

echo -e "sample_id\tgene_name\tnum_diff_alleles\tallele_1\tabundance_1\tquality_1\tallele_2\tabundance_2\tquality_2\tsecondary_alleles" > "$RAW"
grep . "$DIR"/*/*_genotype.tsv | sed 's/_hla_out.*tsv:/\t/g' | sed 's/^..*hla_out\///g' >> "$RAW"

cut -f1,2,4 "$RAW" | sed 's/HLA-//g' | awk '{print $1, $2"_1", $3}' OFS='\t' > "$DIR/allele_1.txt"
cut -f1,2,7 "$RAW" | sed 's/HLA-//g' | awk '{print $1, $2"_2", $3}' OFS='\t' > "$DIR/allele_2.txt"

cat "$DIR/allele_1.txt" "$DIR/allele_2.txt" \
  | sort -k1,2 \
  | datamash -g 1 collapse 3 \
  | sed 's/,/\t/g' > "$SORTED"

echo -e "Sample_ID\tA_1\tA_2\tB_1\tB_2\tC_1\tC_2\tDRB1_1\tDRB1_2" > "$FINAL"
cat "$SORTED" >> "$FINAL"

echo "Final HLA table: $FINAL"
