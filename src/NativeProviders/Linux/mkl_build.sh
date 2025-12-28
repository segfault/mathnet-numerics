#!/usr/bin/env bash

set -eu

# Note: g++ multilib is required for 32-bit builds.
export OUT=../../../out/MKL/Linux

MKLROOT="${MKLROOT:-}"
if [ -z "$MKLROOT" ]; then
    if [ -d /opt/intel/oneapi/mkl/latest ]; then
        MKLROOT=/opt/intel/oneapi/mkl/latest
    else
        MKLROOT="$(ls -d /opt/intel/oneapi/mkl/* 2>/dev/null | sort | tail -n 1 || true)"
    fi
fi

if [ -z "$MKLROOT" ] || [ ! -d "$MKLROOT" ]; then
    echo "Error: MKLROOT not found. Set MKLROOT or install Intel oneAPI MKL." >&2
    exit 1
fi

IOMP5_LIB_DIR="${IOMP5_LIB_DIR:-}"
if [ -z "$IOMP5_LIB_DIR" ]; then
    if [ -n "${ONEAPI_ROOT:-}" ] && [ -d "$ONEAPI_ROOT/compiler/latest/linux/compiler/lib" ]; then
        IOMP5_LIB_DIR="$ONEAPI_ROOT/compiler/latest/linux/compiler/lib"
    elif [ -d /opt/intel/oneapi/compiler/latest/linux/compiler/lib ]; then
        IOMP5_LIB_DIR=/opt/intel/oneapi/compiler/latest/linux/compiler/lib
    else
        for dir in /opt/intel/oneapi/compiler/*/linux/compiler/lib; do
            if [ -f "$dir/intel64_lin/libiomp5.so" ]; then
                IOMP5_LIB_DIR="$dir"
                break
            fi
        done
        if [ -z "$IOMP5_LIB_DIR" ]; then
            for dir in /opt/intel/oneapi/compiler/*/lib; do
                if [ -f "$dir/libiomp5.so" ]; then
                    IOMP5_LIB_DIR="$dir"
                    break
                fi
            done
        fi
    fi
fi

if [ -z "$IOMP5_LIB_DIR" ] || [ ! -d "$IOMP5_LIB_DIR" ]; then
    echo "Error: OpenMP runtime not found. Set IOMP5_LIB_DIR or install Intel oneAPI compiler runtime." >&2
    exit 1
fi

MKL_LIB64="$MKLROOT/lib/intel64"
MKL_LIB32="$MKLROOT/lib/ia32"
if [ -d "$IOMP5_LIB_DIR/intel64_lin" ]; then
    OPENMP64="$IOMP5_LIB_DIR/intel64_lin"
else
    OPENMP64="$IOMP5_LIB_DIR"
fi
if [ -d "$IOMP5_LIB_DIR/ia32_lin" ]; then
    OPENMP32="$IOMP5_LIB_DIR/ia32_lin"
else
    OPENMP32=""
fi

mkdir -p "$OUT/x64"

g++ -std=c++11 -D_M_X64 -DGCC -m64 --shared -fPIC \
    -o "$OUT/x64/libMathNetNumericsMKL.so" \
    -I"$MKLROOT/include" -I../Common -I../MKL \
    ../MKL/memory.c ../MKL/capabilities.cpp ../MKL/vector_functions.c ../Common/blas.c ../Common/lapack.cpp ../MKL/fft.cpp \
    -Wl,--start-group "$MKL_LIB64/libmkl_intel_lp64.a" "$MKL_LIB64/libmkl_intel_thread.a" "$MKL_LIB64/libmkl_core.a" -Wl,--end-group \
    -L"$OPENMP64" -liomp5 -lpthread -lm

cp "$OPENMP64/libiomp5.so" "$OUT/x64/"

if [ -d "$MKL_LIB32" ] && [ -n "$OPENMP32" ] && [ -d "$OPENMP32" ]; then
    mkdir -p "$OUT/x86"
    g++ -std=c++11 -D_M_IX86 -DGCC -m32 --shared -fPIC \
        -o "$OUT/x86/libMathNetNumericsMKL.so" \
        -I"$MKLROOT/include" -I../Common -I../MKL \
        ../MKL/memory.c ../MKL/capabilities.cpp ../MKL/vector_functions.c ../Common/blas.c ../Common/lapack.cpp ../MKL/fft.cpp \
        -Wl,--start-group "$MKL_LIB32/libmkl_intel.a" "$MKL_LIB32/libmkl_intel_thread.a" "$MKL_LIB32/libmkl_core.a" -Wl,--end-group \
        -L"$OPENMP32" -liomp5 -lpthread -lm
    cp "$OPENMP32/libiomp5.so" "$OUT/x86/"
else
    echo "Skipping 32-bit MKL build (ia32 libraries not found)." >&2
fi
