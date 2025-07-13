#!/usr/bin/env bash

# Build the OpenBLAS native provider wrapper for Linux.
# Requires the system packages libopenblas-dev and liblapacke-dev.

set -eu

export OUT=../../../out/OpenBLAS/Linux

mkdir -p "$OUT/x64"
mkdir -p "$OUT/x86"

# 64-bit
g++ -std=c++11 -m64 -fPIC --shared \
    -I../Common -I../OpenBLAS \
    ../Common/blas.c ../Common/lapack.cpp ../OpenBLAS/capabilities.cpp \
    -lopenblas -llapacke \
    -o "$OUT/x64/libMathNetNumericsOpenBLAS.so"

# 32-bit (requires multilib)
g++ -std=c++11 -m32 -fPIC --shared \
    -I../Common -I../OpenBLAS \
    ../Common/blas.c ../Common/lapack.cpp ../OpenBLAS/capabilities.cpp \
    -lopenblas -llapacke \
    -o "$OUT/x86/libMathNetNumericsOpenBLAS.so"