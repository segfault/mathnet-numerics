#!/usr/bin/env sh
export OUT=../../../out/Accelerate/OSX
# Use macOS SDK path for Accelerate headers (supports newer Xcode setups)
SDKROOT=$(xcrun --show-sdk-path)
INCLUDE_ACCELATE="$SDKROOT/System/Library/Frameworks/Accelerate.framework/Headers"
INCLUDE_VECLIB="$SDKROOT/System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Headers"
DEFS="-DACCELERATE_NEW_LAPACK -DACCELERATE_LAPACK_ILP64"

mkdir -p $OUT/x64
mkdir -p $OUT/arm64

# Build for Intel x86_64
clang++ -std=c++11 -arch x86_64 -framework Accelerate -shared -fPIC $DEFS \
    -o $OUT/x64/libMathNetNumericsAccelerate.dylib \
    -I../Common -I. -I"$INCLUDE_ACCELATE" -I"$INCLUDE_VECLIB" \
    ../Common/blas.c capabilities.cpp

# Build for Apple silicon arm64
clang++ -std=c++11 -arch arm64 -framework Accelerate -shared -fPIC $DEFS \
    -o $OUT/arm64/libMathNetNumericsAccelerate.dylib \
    -I../Common -I. -I"$INCLUDE_ACCELATE" -I"$INCLUDE_VECLIB" \
    ../Common/blas.c capabilities.cpp
