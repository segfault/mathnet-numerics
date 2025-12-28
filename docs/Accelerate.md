# Apple Accelerate Native Provider

Math.NET Numerics includes a native provider for Apple's built-in Accelerate framework, offering optimized BLAS and LAPACK routines on macOS (Intel and Apple Silicon).

## Building the provider

```sh
cd src/NativeProviders/OSX
sh accelerate_build.sh
```

This creates the `libMathNetNumericsAccelerate.dylib` libraries for x64 and arm64 under `out/Accelerate/OSX/x64` and `out/Accelerate/OSX/arm64`.

## Native package

If you prefer prebuilt binaries, install `MathNet.Numerics.Accelerate.OSX` alongside `MathNet.Numerics.Providers.Accelerate`. The native dylibs will be resolved from the NuGet runtime assets, so you do not need to set `Control.NativeProviderPath`.

## Using the provider

In C#:
```csharp
using MathNet.Numerics;
using MathNet.Numerics.Providers.Accelerate;

Control.NativeProviderPath = "/path/to/mathnet-numerics/out/Accelerate/OSX";
Control.UseNativeAccelerate();
```

In F# Interactive:
```fsharp
#r "nuget: MathNet.Numerics"
#r "nuget: MathNet.Numerics.Providers.Accelerate"

open MathNet.Numerics
open MathNet.Numerics.Providers.Accelerate

Control.NativeProviderPath <- "/path/to/mathnet-numerics/out/Accelerate/OSX"
Control.UseNativeAccelerate()
```
