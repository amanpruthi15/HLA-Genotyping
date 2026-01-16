#!/bin/bash

sample_info_file="$1"
wd="$2"

reference="/home/act/HLA_genotyping/T1K_Database/hlaidx/hlaidx_dna_seq.fa"

job_files_dir="${wd}/job_files"
job_output_dir="${wd}/job_output"
job_error_dir="${wd}/job_error"

mkdir -p "$job_files_dir" "$job_output_dir" "$job_error_dir"

tail -n +2 "$sample_info_file" | while read -r sample; do
  r1=$(ls -1 ${wd}/download/*${sample}*_*1*.fastq.gz 2>/dev/null | head -n 1 || true)
  r2=$(ls -1 ${wd}/download/*${sample}*_*2*.fastq.gz 2>/dev/null | head -n 1 || true)
  outdir="${wd}/hla_out/${sample}_hla_out"

  [[ ! -f "$r1" || ! -f "$r2" ]] && continue

  mkdir -p "$outdir"
  job_file="${job_files_dir}/hlaT1K_${sample}.sh"

  cat <<EOF > "$job_file"
#!/bin/bash
#SBATCH --job-name=hlaT1K_${sample}
#SBATCH --output=${job_output_dir}/hlaT1K_${sample}_%j.out
#SBATCH --error=${job_error_dir}/hlaT1K_${sample}_%j.err
#SBATCH --cpus-per-task=4

run-t1k \\
  -1 ${r1} \\
  -2 ${r2} \\
  -f ${reference} \\
  --od ${outdir} \\
  -o ${sample} \\
  -t 4 --preset hla
EOF

  sbatch "$job_file"
done
