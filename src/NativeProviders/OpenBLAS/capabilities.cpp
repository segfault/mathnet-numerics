#include "wrapper_common.h"
#include "blas.h"
#if defined(BLIS_INT_TYPE_SIZE)
#include "blis.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

	/*
		Capability is supported if >0

		Actual number can be increased over time to indicate
		extensions/revisions (that do not break compatibility)
	*/
	DLLEXPORT int query_capability(const int capability)
	{
		switch (capability)
		{

		// SANITY CHECKS
		case 0:	return 0;
		case 1:	return -1;

		// PLATFORM
		case 8:
#ifdef _M_IX86
			return 1;
#else
			return 0;
#endif
		case 9:
#ifdef _M_X64
			return 1;
#else
			return 0;
#endif
		case 10:
#ifdef _M_IA64
			return 1;
#else
			return 0;
#endif

		// COMMON/SHARED
		case 64: return 1; // revision
		case 66: return 1; // threading control

		// LINEAR ALGEBRA
		case 128: return 1;	// basic dense linear algebra (major - breaking)
		case 129: return 0;	// basic dense linear algebra (minor - non-breaking)

		default: return 0; // unknown or not supported

		}
	}

	DLLEXPORT void set_max_threads(const blasint num_threads)
	{
#if defined(BLIS_INT_TYPE_SIZE)
		bli_thread_set_num_threads((dim_t)num_threads);
#else
		openblas_set_num_threads(num_threads);
#endif
	}

	DLLEXPORT char* get_build_config()
	{
#if defined(BLIS_INT_TYPE_SIZE)
		static char config[] = "AOCL BLIS";
		return config;
#else
		return openblas_get_config();
#endif
	}

	DLLEXPORT char* get_cpu_core()
	{
#if defined(BLIS_INT_TYPE_SIZE)
		static char core[] = "AOCL";
		return core;
#else
		return openblas_get_corename();
#endif
	}

	DLLEXPORT int get_parallel_type()
	{
#if defined(BLIS_INT_TYPE_SIZE)
		return 0;
#else
		return openblas_get_parallel();
#endif
	}

#ifdef __cplusplus
}
#endif /* __cplusplus */
