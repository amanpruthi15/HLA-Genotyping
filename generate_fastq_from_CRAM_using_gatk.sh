#!/bin/bash

# Usage:
# ./generate_cram2fastq_slurms.sh Sample-Info.txt /full/path/to/working_dir /full/path/to/GRCh38_reference_genome

set -euo pipefail

sample_info="$1"
working_dir="$2"
ref_dir="$3"
ref_fa="GRCh38_full_analysis_set_plus_decoy_hla.fa"
ref_path="${ref_dir}/${ref_fa}"

# Define working subdirectories
download_dir="${working_dir}/download"
cram_dir="${working_dir}/cram"
job_files_dir="${working_dir}/job_files"
job_output_dir="${working_dir}/job_output"
job_error_dir="${working_dir}/job_error"
mkdir -p "$job_files_dir" "$job_output_dir" "$job_error_dir"

# Skip header
tail -n +2 "$sample_info" | while read -r sample; do
    fq1=$(ls -1 ${download_dir}/*${sample}*_*1*.fastq.gz 2>/dev/null | head -n 1 || true)
    fq2=$(ls -1 ${download_dir}/*${sample}*_*2*.fastq.gz 2>/dev/null | head -n 1 || true)
    cram_file=$(ls -1 ${cram_dir}/*${sample}*.cram 2>/dev/null | head -n 1 || true)

    # Skip if FASTQs already exist
    if [[ -s "$fq1" && -s "$fq2" ]]; then
        echo "Skipping ${sample} — FASTQs already exist."
        continue
    fi

    # Skip if CRAM not found
    if [[ ! -f "$cram_file" ]]; then
        echo "Skipping ${sample} — CRAM file not found in ${cram_dir}."
        continue
    fi

    job_file="${job_files_dir}/${sample}_cram2fq.slurm"

    cat > "$job_file" <<EOF
#!/bin/bash
#SBATCH --job-name=cram2fastq_${sample}
#SBATCH --output=${job_output_dir}/cram2fastq_${sample}_%j.out
#SBATCH --error=${job_error_dir}/cram2fastq_${sample}_%j.err
#SBATCH --cpus-per-task=4

echo "Converting CRAM to FASTQ for ${sample}..."

docker run --rm \\
    -v ${working_dir}:/data \\
    -v ${ref_dir}:/ref \\
    broadinstitute/gatk:4.4.0.0 \\
    java -jar /root/gatk.jar SamToFastq \\
    -I /data/cram/${sample}.cram \\
    -F /data/download/*${sample}*_*1*.fastq.gz \\
    -F2 /data/download/*${sample}*_*2*.fastq.gz \\
    -R /ref/${ref_fa} \\
    --VALIDATION_STRINGENCY LENIENT
EOF

    sbatch "$job_file"
done
