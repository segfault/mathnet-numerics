// <copyright file="SobolRandomSource.cs" company="Math.NET">
// Math.NET Numerics, part of the Math.NET Project
// http://numerics.mathdotnet.com
// http://github.com/mathnet/mathnet-numerics
//
// Copyright (c) 2009-2025 Math.NET
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// </copyright>

using System;
using System.Runtime.Serialization;

namespace MathNet.Numerics.Random
{
    /// <summary>
    /// One-dimensional Sobol low-discrepancy sequence with Gray code ordering and optional Owen scrambling.
    /// </summary>
    [Serializable]
    [DataContract(Namespace = "urn:MathNet/Numerics/Random")]
    public class SobolRandomSource : RandomSource
    {
        const double Reciprocal = 1.0 / 18446744073709551616.0; // 2^-64

        static readonly ulong[] Directions = CreateDirections();

        [DataMember(Order = 1)]
        readonly bool _owenScramble;

        [DataMember(Order = 2)]
        readonly ulong _scrambleSeed;

        [DataMember(Order = 3)]
        ulong _index;

        public SobolRandomSource()
            : this(RandomSeed.Robust(), Control.ThreadSafeRandomNumberGenerators, true)
        {
        }

        public SobolRandomSource(bool threadSafe)
            : this(RandomSeed.Robust(), threadSafe, true)
        {
        }

        public SobolRandomSource(int seed)
            : this(seed, Control.ThreadSafeRandomNumberGenerators, true)
        {
        }

        public SobolRandomSource(int seed, bool threadSafe)
            : this(seed, threadSafe, true)
        {
        }

        public SobolRandomSource(int seed, bool threadSafe, bool owenScramble)
            : base(threadSafe)
        {
            _owenScramble = owenScramble;
            _scrambleSeed = (ulong)seed;
        }

        protected override double DoSample()
        {
            _index++;
            ulong g = _index ^ (_index >> 1);
            ulong value = 0UL;

            if (_owenScramble)
            {
                ulong prefix = 0UL;
                for (int bit = 63; bit >= 0; bit--)
                {
                    ulong gbit = (g >> bit) & 1UL;
                    ulong sbit = OwenScrambleBit(prefix, bit);
                    ulong obit = gbit ^ sbit;
                    if (obit != 0UL)
                    {
                        value ^= Directions[bit];
                    }

                    prefix = (prefix << 1) | obit;
                }
            }
            else
            {
                for (int bit = 0; bit < 64; bit++)
                {
                    if (((g >> bit) & 1UL) != 0UL)
                    {
                        value ^= Directions[bit];
                    }
                }
            }

            return value * Reciprocal;
        }

        static ulong[] CreateDirections()
        {
            var directions = new ulong[64];
            for (int i = 0; i < directions.Length; i++)
            {
                directions[i] = 1UL << (63 - i);
            }
            return directions;
        }

        ulong OwenScrambleBit(ulong prefix, int bit)
        {
            ulong x = _scrambleSeed;
            x ^= (ulong)bit * 0x9E3779B97F4A7C15UL;
            x ^= prefix + 0xD2B74407B1CE6E93UL;
            x = Mix64(x);
            return x & 1UL;
        }

        static ulong Mix64(ulong z)
        {
            z += 0x9E3779B97F4A7C15UL;
            z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9UL;
            z = (z ^ (z >> 27)) * 0x94D049BB133111EBUL;
            return z ^ (z >> 31);
        }
    }
}
