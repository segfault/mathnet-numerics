#pragma once

#define blas_int int
#define blas_complex_float Complex8
#define blas_complex_double Complex16
#include <cblas.h>

typedef struct { float real; float imag; } Complex8;
typedef struct { double real; double imag; } Complex16;