#!/usr/bin/env bash

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${OUT:-$SCRIPT_DIR/../../../out/OpenBLAS/AOCL/Linux}"
export OUT

AOCL_ROOT="${AOCL_ROOT:-}"
if [ -z "$AOCL_ROOT" ] && [ -d /opt/AMD/aocl/aocl-linux-aocc-5.1.0/aocc ]; then
    AOCL_ROOT=/opt/AMD/aocl/aocl-linux-aocc-5.1.0/aocc
fi

if [ -z "$AOCL_ROOT" ]; then
    echo "Error: AOCL_ROOT not set and default AOCL path not found." >&2
    exit 1
fi

export AOCL_ROOT
export AOCL_FORCE=1

bash "$SCRIPT_DIR/openblas_build.sh"
