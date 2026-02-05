#!/bin/bash

cd "$(dirname "$0")"
set -e

# ---------------------
# Parse external parameters
# ---------------------
threads=$(nproc)
model="full"
parallel_jobs=5  # default parallel jobs

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) model="$2"; shift 2;;
        --threads) threads="$2"; shift 2;;
        --parallel_jobs) parallel_jobs="$2"; shift 2;;
        --species) species="$2"; shift 2;;
        --input_dir) input_dir="$2"; shift 2;;
        --output_dir) output_dir="$2"; shift 2;;
        *) echo "Unknown parameter: $1"; exit 1;;
    esac
done

# Required parameters check
if [[ -z "$species" || -z "$input_dir" || -z "$output_dir" ]]; then
    echo "Usage: $0 --species hsa/mmu --input_dir DIR --output_dir DIR [--model full|mixcr|barcode_preprocessing|meta_build] [--parallel_jobs N]"
    exit 1
fi

# Detect paired FASTQ files
r1_files=($(find "$input_dir" -name "*_read_1.part_*.matched.fq.gz" | sort))
r2_files=($(find "$input_dir" -name "*_read_2.part_*.barcode.fq.gz" | sort))
if [ ${#r1_files[@]} -eq 0 ] || [ ${#r1_files[@]} -ne ${#r2_files[@]} ]; then
    echo "Error: Could not find paired R1 and R2 files, or counts mismatch!"
    echo "R1 files: ${#r1_files[@]}"
    echo "R2 files: ${#r2_files[@]}"
    exit 1
fi
echo "Detected ${#r1_files[@]} file pairs."

# Extract sample name from first file
sample=$(basename "${r1_files[0]}" | sed -E 's/(.+)_read_1\.part_[0-9]+\.matched\.fq\.gz/\1/')

mixcr_dir=${output_dir}/02.mixcr
raw_meta_dir=${output_dir}/03.raw_meta
mkdir -p ${mixcr_dir} ${raw_meta_dir}

# ---------------------
# Function for processing single file pair
# ---------------------
process_single_pair() {
    local idx=$1
    local r1_file=$2
    local r2_file=$3
    local part_num=$(printf "%03d" $idx)
    local mixcr_subdir="${mixcr_dir}/${part_num}"
    local raw_meta_subdir="${raw_meta_dir}/${part_num}"
    mkdir -p "$mixcr_subdir" "$raw_meta_subdir"
    echo "Processing file pair $part_num: $(basename "$r1_file") & $(basename "$r2_file")"

    # MixCR alignment and AIRR conversion
    if [[ "$model" == "full" || "$model" == "mixcr" ]]; then
        echo "Running MIXCR for pair $part_num"
        bash ./MIXCR_all.sh \
            "${species}" \
            "${mixcr_subdir}" \
            "${sample}" \
            "${r1_file}" \
            "${mixcr_subdir}" \
            "${threads}"
        echo "MIXCR finished for pair $part_num"
    fi

    # Barcode preprocessing
    if [[ "$model" == "full" || "$model" == "barcode_preprocessing" ]]; then
        echo "Running barcode preprocessing for pair $part_num"
        ../rust/barcode_processor/target/release/barcode_processor \
          --mixcr-align-file "${mixcr_subdir}/${sample}.align.tsv" \
          --barcode-fq-gz "${r2_file}" \
          --out-barcode-matched "${raw_meta_subdir}/${sample}_barcode.matched.tsv" \
          --threads "${threads}" \
          --batch-size 100000
        echo "Barcode preprocessing finished for pair $part_num"
    fi

    # Meta build step
    if [[ "$model" == "full" || "$model" == "meta_build" ]]; then
        echo "Running meta_build for pair $part_num"
        ../rust/meta_build/target/release/meta_build \
          --mixcr-clone-file "${mixcr_subdir}/${sample}.airr.tsv" \
          --mixcr-align-file "${mixcr_subdir}/${sample}.align.tsv" \
          --barcode-tsv-file "${raw_meta_subdir}/${sample}_barcode.matched.tsv" \
          --outmeta-file "${raw_meta_subdir}/${sample}.meta" \
          --threads "${threads}" \
          --batch-size 100000
        echo "Meta build finished for pair $part_num"
    fi
}
