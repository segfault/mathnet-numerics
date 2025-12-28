#pragma once

#if defined(__has_include)
#if __has_include(<openblas64_config.h>)
#include <openblas64_config.h>
#elif __has_include(<openblas_config.h>)
#include <openblas_config.h>
#endif
#else
#include <openblas_config.h>
#endif

#include "cblas.h"

#define blas_int blasint
#define blas_complex_float openblas_complex_float
#define blas_complex_double openblas_complex_double
