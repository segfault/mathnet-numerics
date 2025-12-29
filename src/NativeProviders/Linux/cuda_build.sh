#!/usr/bin/env bash

# Build the CUDA native provider wrapper for Linux (x64).
# Requires a CUDA toolkit installation (cublas, cusolver, cudart).

set -eu

OUT="${OUT:-../../../out/CUDA/Linux}"
export OUT

mkdir -p "$OUT/x64"

CUDA_HOME="${CUDA_HOME:-${CUDA_PATH:-}}"
if [ -z "$CUDA_HOME" ]; then
    if [ -d /usr/local/cuda ]; then
        CUDA_HOME=/usr/local/cuda
    fi
fi

if [ -z "$CUDA_HOME" ] || [ ! -d "$CUDA_HOME" ]; then
    echo "Error: CUDA_HOME (or CUDA_PATH) not set and /usr/local/cuda not found." >&2
    exit 1
fi

CUDA_INC="$CUDA_HOME/include"
CUDA_LIB=""
for dir in "$CUDA_HOME/lib64" "$CUDA_HOME/targets/x86_64-linux/lib" "$CUDA_HOME/lib"; do
    if [ -d "$dir" ]; then
        CUDA_LIB="$dir"
        break
    fi
done

if [ -z "$CUDA_LIB" ]; then
    echo "Error: CUDA library directory not found under $CUDA_HOME." >&2
    exit 1
fi

g++ -std=c++11 -fPIC --shared \
    -I../Common -I../CUDA -I"$CUDA_INC" \
    ../CUDA/blas.cpp ../CUDA/lapack.cpp ../CUDA/capabilities.cpp ../CUDA/memory.c \
    -L"$CUDA_LIB" -lcudart -lcublas -lcusolver -ldl -lpthread \
    -o "$OUT/x64/libMathNetNumericsCUDA.so"
