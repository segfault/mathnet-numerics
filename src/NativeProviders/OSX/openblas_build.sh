#!/usr/bin/env bash

# Build the OpenBLAS native provider wrapper for macOS.
# Requires the system package OpenBLAS and Lapacke (e.g. via Homebrew or MacPorts).

set -eu

export OUT=../../../out/OpenBLAS/OSX

mkdir -p "$OUT/x64"
mkdir -p "$OUT/arm64"

# x64 architecture
g++ -std=c++11 -arch x86_64 -dynamiclib -fPIC \
    -I../Common -I../OpenBLAS \
    ../Common/blas.c ../Common/lapack.cpp ../OpenBLAS/capabilities.cpp \
    -lopenblas -llapacke \
    -o "$OUT/x64/libMathNetNumericsOpenBLAS.dylib"

# arm64 architecture
g++ -std=c++11 -arch arm64 -dynamiclib -fPIC \
    -I../Common -I../OpenBLAS \
    ../Common/blas.c ../Common/lapack.cpp ../OpenBLAS/capabilities.cpp \
    -lopenblas -llapacke \
    -o "$OUT/arm64/libMathNetNumericsOpenBLAS.dylib"