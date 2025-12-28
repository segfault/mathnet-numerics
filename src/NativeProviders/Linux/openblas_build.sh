#!/usr/bin/env bash

# Build the OpenBLAS native provider wrapper for Linux.
# Requires the system packages libopenblas-dev and liblapacke-dev.

set -eu

export OUT=../../../out/OpenBLAS/Linux

mkdir -p "$OUT/x64"

OPENBLAS_CFLAGS="${OPENBLAS_CFLAGS:-}"
OPENBLAS_LIBS="${OPENBLAS_LIBS:-}"
LAPACKE_CFLAGS="${LAPACKE_CFLAGS:-}"
LAPACKE_LIBS="${LAPACKE_LIBS:-}"

if command -v pkg-config >/dev/null 2>&1; then
    OPENBLAS_CFLAGS="${OPENBLAS_CFLAGS:-$(pkg-config --cflags openblas64 2>/dev/null || true)}"
    OPENBLAS_LIBS="${OPENBLAS_LIBS:-$(pkg-config --libs openblas64 2>/dev/null || true)}"
    if [ -z "$OPENBLAS_CFLAGS" ] && [ -z "$OPENBLAS_LIBS" ]; then
        OPENBLAS_CFLAGS="${OPENBLAS_CFLAGS:-$(pkg-config --cflags openblas 2>/dev/null || true)}"
        OPENBLAS_LIBS="${OPENBLAS_LIBS:-$(pkg-config --libs openblas 2>/dev/null || true)}"
    fi
    LAPACKE_CFLAGS="${LAPACKE_CFLAGS:-$(pkg-config --cflags lapacke 2>/dev/null || true)}"
    LAPACKE_LIBS="${LAPACKE_LIBS:-$(pkg-config --libs lapacke 2>/dev/null || true)}"
    if [ -z "$LAPACKE_CFLAGS" ] && [ -z "$LAPACKE_LIBS" ]; then
        LAPACKE_CFLAGS="$(pkg-config --cflags lapacke64 2>/dev/null || true)"
        LAPACKE_LIBS="$(pkg-config --libs lapacke64 2>/dev/null || true)"
    fi
fi

if [ -z "$OPENBLAS_CFLAGS" ]; then
    for dir in /usr/include/openblas /usr/include/x86_64-linux-gnu/openblas /usr/include/x86_64-linux-gnu/openblas64-pthread /usr/local/include/openblas; do
        if [ -f "$dir/openblas_config.h" ] || [ -f "$dir/openblas64_config.h" ]; then
            OPENBLAS_CFLAGS="-I$dir"
            break
        fi
    done
fi

if [ -z "$LAPACKE_CFLAGS" ]; then
    for dir in /usr/include /usr/local/include; do
        if [ -f "$dir/lapacke.h" ]; then
            LAPACKE_CFLAGS="-I$dir"
            break
        fi
    done
fi

if [ -z "$OPENBLAS_LIBS" ]; then
    OPENBLAS_LIBS="-lopenblas"
fi

if [ -z "$LAPACKE_LIBS" ]; then
    LAPACKE_LIBS="-llapacke"
fi

if [ -z "$LAPACKE_CFLAGS" ]; then
    echo "Error: lapacke.h not found. Please install liblapacke-dev or liblapacke64-dev (or set LAPACKE_CFLAGS/LAPACKE_LIBS)." >&2
    exit 1
fi

# 64-bit
g++ -std=c++11 -m64 -fPIC --shared \
    -I../Common -I../OpenBLAS \
    $OPENBLAS_CFLAGS $LAPACKE_CFLAGS \
    ../Common/blas.c ../Common/lapack.cpp ../OpenBLAS/capabilities.cpp \
    $OPENBLAS_LIBS $LAPACKE_LIBS \
    -o "$OUT/x64/libMathNetNumericsOpenBLAS.so"

X86_OPENBLAS_LIBDIR=""
for dir in /usr/lib/i386-linux-gnu /usr/lib32 /usr/lib; do
    if [ -f "$dir/libopenblas.so" ] || [ -f "$dir/libopenblas.a" ]; then
        X86_OPENBLAS_LIBDIR="$dir"
        break
    fi
done

if [ -n "$X86_OPENBLAS_LIBDIR" ]; then
    mkdir -p "$OUT/x86"
    g++ -std=c++11 -m32 -fPIC --shared \
        -I../Common -I../OpenBLAS \
        $OPENBLAS_CFLAGS $LAPACKE_CFLAGS \
        ../Common/blas.c ../Common/lapack.cpp ../OpenBLAS/capabilities.cpp \
        -L"$X86_OPENBLAS_LIBDIR" $OPENBLAS_LIBS $LAPACKE_LIBS \
        -o "$OUT/x86/libMathNetNumericsOpenBLAS.so"
else
    echo "Skipping 32-bit OpenBLAS build (no 32-bit OpenBLAS libs found)." >&2
fi
