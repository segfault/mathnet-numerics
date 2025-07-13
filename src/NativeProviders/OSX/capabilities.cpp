#include "wrapper_common.h"

#ifdef __cplusplus
extern "C" {
#endif

DLLEXPORT int query_capability(const int capability)
{
    switch (capability)
    {
    case 0: return 0;
    case 1: return -1;

    case 8:
#ifdef __i386__
        return 1;
#else
        return 0;
#endif
    case 9:
#ifdef __x86_64__
        return 1;
#else
        return 0;
#endif
    case 11:
#ifdef __arm__
        return 1;
#else
        return 0;
#endif
    case 12:
#ifdef __aarch64__
        return 1;
#else
        return 0;
#endif

    case 64: return 1;  // revision
    case 66: return 0;  // threading control

    case 128: return 1; // linear algebra (major)
    case 129: return 0; // linear algebra (minor)

    default: return 0;
    }
}

DLLEXPORT void set_max_threads(const int num_threads)
{
    // No-op: threading is managed by the Accelerate framework or OS
}

#ifdef __cplusplus
}
#endif