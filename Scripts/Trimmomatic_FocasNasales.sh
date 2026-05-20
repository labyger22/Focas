#!/usr/bin/env bash

java -Xmx32g -jar /home/camilo/miniconda3/envs/bioenv2/share/trimmomatic-0.40-0/trimmomatic.jar \
PE \
-threads 40 \
-phred33 \
-trimlog salida/SE01_trim_5_5_420_150.log \
01.RawData_Focas/SES01_A/SES01_A_CKDL250029488-1A_233732LT3_L4_1.fq.gz \
01.RawData_Focas/SES01_A/SES01_A_CKDL250029488-1A_233732LT3_L4_2.fq.gz \
-baseout salida/SE01_TRIM5.fq.gz \
ILLUMINACLIP:/home/camilo/miniconda3/envs/bioenv2/share/trimmomatic/adapters/TruSeq3-PE-2-GGGGG.fa:2:30:10 \
LEADING:10 \
TRAILING:10 \
SLIDINGWINDOW:4:20 \
MINLEN:100 



for DIR in 01.RawData_FocasNasales/*_N; do
  SAMPLE=$(basename "$DIR")

  R1=$(ls $DIR/*_L4_1.fq.gz)
  R2=$(ls $DIR/*_L4_2.fq.gz)

  echo ">>> Procesando $SAMPLE"

  java -Xmx32g -jar /home/camilo/miniconda3/envs/bioenv2/share/trimmomatic-0.40-0/trimmomatic.jar \
  PE \
  -threads 40 \
  -phred33 \
  -trimlog 02.TrimmedData_FocasNasales/${SAMPLE}_10_10_420_100.log \
  "$R1" "$R2" \
  -baseout 02.TrimmedData_FocasNasales/${SAMPLE}_10_10_420_100.fq.gz \
  ILLUMINACLIP:/home/camilo/miniconda3/envs/bioenv2/share/trimmomatic/adapters/TruSeq3-PE-2-GGGGG.fa:2:30:10 \
  LEADING:10 \
  TRAILING:10 \
  SLIDINGWINDOW:4:20 \
  MINLEN:100

  echo ">>> OK $SAMPLE"
  echo
done