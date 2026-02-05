species=$1
MIXCR_OUT_DIR=$2
SAMPLE=$3
INPUT_READ1=$4
REPORT_DIR=$5
THREADS=$6

# mixcr align
../tools/mixcr/mixcr align \
    -p rna-seq \
    -Xmx50g \
    --threads ${THREADS} \
    --species ${species} \
    -f \
    -OsaveOriginalReads=true \
    -OallowPartialAlignments=true \
    -OvParameters.geneFeatureToAlign="VTranscriptWithout5UTRWithP" \
    --report ${MIXCR_OUT_DIR}/${SAMPLE}.align.report.txt \
    --json-report ${MIXCR_OUT_DIR}/${SAMPLE}.align.report.json \
    ${INPUT_READ1} \
    ${MIXCR_OUT_DIR}/${SAMPLE}.vdjca

../tools/mixcr/mixcr assemble \
    -Xmx50g \
    -f \
    -OassemblingFeatures='CDR3' \
    -OseparateByJ=true\
    -OseparateByV=true \
    -a \
    --report ${MIXCR_OUT_DIR}/${SAMPLE}.assemble.report.txt \
    --json-report ${MIXCR_OUT_DIR}/${SAMPLE}.assemble.report.json \
    ${MIXCR_OUT_DIR}/${SAMPLE}.vdjca \
    ${MIXCR_OUT_DIR}/${SAMPLE}.clna

../tools/mixcr/mixcr exportAirr \
    -Xmx50g \
    -f \
    ${MIXCR_OUT_DIR}/${SAMPLE}.clna \
    ${MIXCR_OUT_DIR}/${SAMPLE}.airr.tsv

../tools/mixcr/mixcr exportAlignments \
    -Xmx50g \
    -readIds \
    -descrsR1 \
    -cloneId \
    -isotype auto \
    -f \
    ${MIXCR_OUT_DIR}/${SAMPLE}.clna \
    ${MIXCR_OUT_DIR}/${SAMPLE}.align.tsv

# 提取 mixcr align 报告信息
echo "=================== 提取 mixcr align 报告信息 ==================="
ALIGN_REPORT="${MIXCR_OUT_DIR}/${SAMPLE}.align.report.txt"

if [ -f "$ALIGN_REPORT" ]; then
    # 获取子目录编号用于报告文件名
    SUBDIR_NUM=$(basename "$MIXCR_OUT_DIR")
    
    {
        echo "=================== MIXCR Align Report - Part ${SUBDIR_NUM} ==================="
        echo "处理时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "输入文件: ${INPUT_READ1}"
        echo
        
        # 提取关键统计信息
        grep "Total sequencing reads:" "$ALIGN_REPORT"
        grep "Successfully aligned reads:" "$ALIGN_REPORT"
        grep "TRA chains:" "$ALIGN_REPORT"
        grep "TRB chains:" "$ALIGN_REPORT"
        grep "IGH chains:" "$ALIGN_REPORT"
        grep "IGK chains:" "$ALIGN_REPORT"
        grep "IGL chains:" "$ALIGN_REPORT"
        grep "TRD chains:" "$ALIGN_REPORT"
        grep "TRG chains:" "$ALIGN_REPORT"
        
        echo
        echo "==========================================================="
    } > ${REPORT_DIR}/S02.mixcr_align_report_${SUBDIR_NUM}.log

    echo "mixcr align 报告已保存到: ${REPORT_DIR}/S02.mixcr_align_report_${SUBDIR_NUM}.log"
else
    echo "警告: mixcr align 报告文件不存在: $ALIGN_REPORT"
fi