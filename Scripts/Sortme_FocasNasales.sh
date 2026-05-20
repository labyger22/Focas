#!/bin/bash
# ===========================================================
# Ejecuta SortMeRNA sobre todas las muestras emparejadas (1P y 2P)
# Guarda lecturas alineadas (rRNA) y no alineadas (no-rRNA)
# Crea los índices una sola vez y los reutiliza en todas las muestras
# ===========================================================

set -euo pipefail

# --- Configuración ---
#REF son las databases
REF_DIR="/data/Labyger/sortme"
#La carpeta de trimmed data 
TRIM_DIR="/data/Labyger/Focas/02.TrimmedData_FocasNasales"
#Ponen los resultados
OUT_DIR="/data/Labyger/Focas/03.Sortmerna_FocasNasales" 
#Creación de carpetas de ida y vuelta
WORKDIR_BASE="/data/Labyger/Focas/03.Sortmerna_FocasNasalesWorkdir"
INDEX_DIR="${WORKDIR_BASE}/index"
THREADS=50
INDEX_THREADS=20

# --- Archivos de referencia ---
REFS=(
  "${REF_DIR}/silva-euk-28s-id98.fasta"
  "${REF_DIR}/silva-euk-18s-id95.fasta"
  "${REF_DIR}/silva-bac-23s-id98.fasta"
  "${REF_DIR}/silva-bac-16s-id90.fasta"
  "${REF_DIR}/silva-arc-23s-id98.fasta"
  "${REF_DIR}/silva-arc-16s-id95.fasta"
  "${REF_DIR}/rfam-5s-database-id98.fasta"
  "${REF_DIR}/rfam-5.8s-database-id98.fasta"
)

#Fechas libreria o disponible de datos este año o fin de año, cada base de datos se tiene que ir actualiaando, sino con eso nom+as

# --- Preparación de carpetas ---
mkdir -p "$OUT_DIR" "$WORKDIR_BASE" "$INDEX_DIR"

# ===========================================================
# 1️⃣ Crear índices una sola vez
# ===========================================================
echo "🔧 Creando índices (solo se ejecuta una vez)..."
if [ ! -d "$INDEX_DIR/idx" ] || [ -z "$(ls -A "$INDEX_DIR/idx" 2>/dev/null || true)" ]; then
    mkdir -p "$INDEX_DIR/kvdb"
    echo "🚀 Iniciando creación de índices..."
    sortmerna \
        $(for ref in "${REFS[@]}"; do echo --ref "$ref"; done) \
        --workdir "$INDEX_DIR" \
        --threads "$INDEX_THREADS" \
        --index \
        --disable-mapping
    echo "✅ Índices creados en $INDEX_DIR"
else
    echo "⚡ Índices ya existen en $INDEX_DIR, se reutilizan."
fi

# ===========================================================
# 2️⃣ Procesar todas las muestras emparejadas
# ===========================================================
for file1 in ${TRIM_DIR}/*_1P.fq.gz; do
    base=$(basename "$file1" "_1P.fq.gz")
    file2="${TRIM_DIR}/${base}_2P.fq.gz"

    if [[ -f "$file2" ]]; then
        echo "=============================================="
        echo "🧬 Procesando muestra: $base"
        echo "Archivos: $file1 y $file2"
        echo "=============================================="

        SAMPLE_WORKDIR="${WORKDIR_BASE}/${base}"
        SAMPLE_KVDB="${SAMPLE_WORKDIR}/kvdb"

        mkdir -p "$SAMPLE_WORKDIR"
        rm -rf "$SAMPLE_KVDB"        # limpia cualquier rastro anterior
        mkdir -p "$SAMPLE_KVDB"      # kvdb vacío para esta muestra

        OUT_OTHER="${OUT_DIR}/${base}_no_rRNA.fq"
        OUT_ALIGNED="${OUT_DIR}/${base}_rRNA.fq"

        # --- Ejecuta SortMeRNA reutilizando índices y kvdb limpio ---
        sortmerna \
            $(for ref in "${REFS[@]}"; do echo --ref "$ref"; done) \
            --reads "$file1" \
            --reads "$file2" \
            --aligned "$OUT_ALIGNED" \
            --other "$OUT_OTHER" \
            --out2 \
            --fastx \
            --threads "$THREADS" \
            --workdir "$SAMPLE_WORKDIR" \
            --gzip \
            --paired_in

        echo "✅ Finalizado: $base"
        echo
    else
        echo "⚠️  No se encontró el par para $file1"
    fi
done

echo "🎉 Todos los procesos completados correctamente."




