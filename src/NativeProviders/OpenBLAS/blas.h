#pragma once

#if !defined(AOCL_BLIS)
#if defined(__has_include)
#if __has_include(<openblas64_config.h>)
#include <openblas64_config.h>
#elif __has_include(<openblas_config.h>)
#include <openblas_config.h>
#endif
#endif
#endif

#include "cblas.h"

#define blas_int blasint
#define blas_complex_float openblas_complex_float
#define blas_complex_double openblas_complex_double

#if defined(BLIS_INT_TYPE_SIZE) && !defined(OPENBLAS_CONFIG_H)
typedef f77_int blasint;
typedef scomplex openblas_complex_float;
typedef dcomplex openblas_complex_double;
#undef blas_int
#undef blas_complex_float
#undef blas_complex_double
#define blas_int blasint
#define blas_complex_float openblas_complex_float
#define blas_complex_double openblas_complex_double
#endif
