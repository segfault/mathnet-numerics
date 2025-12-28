#pragma once

#define LAPACK_COMPLEX_CUSTOM
#include <complex>
#define lapack_complex_float std::complex<float>
#define lapack_complex_double std::complex<double>

#include "cblas.h"
#if defined(__has_include)
#if __has_include("lapacke.h")
#include "lapacke.h"
#elif __has_include(<lapacke.h>)
#include <lapacke.h>
#elif __has_include("mkl_lapacke.h")
#include "mkl_lapacke.h"
#elif __has_include(<mkl_lapacke.h>)
#include <mkl_lapacke.h>
#else
#include "lapacke.h"
#endif
#else
#include "lapacke.h"
#endif
