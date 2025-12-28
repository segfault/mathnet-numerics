#pragma once

#include <cstddef>
#include <cstring>

const int INSUFFICIENT_MEMORY = -999999;

#ifndef LAPACK_MEMORY
#define LAPACK_MEMORY
#include <memory>

template <typename T> using array_ptr = std::unique_ptr<T[]>;

template<typename T>
inline array_ptr<T> array_new(const std::size_t size)
{
	return array_ptr<T>(new T[size]);
}

#endif

template<typename T>
inline array_ptr<T> array_clone(const std::size_t size, const T* array)
{
	auto clone = array_new<T>(size);
	memcpy(clone.get(), array, size * sizeof(T));
	return clone;
}

template<typename T>
inline void shift_ipiv_down(T m, T ipiv[])
{
	for (T i = 0; i < m; ++i)
	{
		ipiv[static_cast<std::size_t>(i)] -= 1;
	}
}

template<typename T>
inline void shift_ipiv_up(T m, T ipiv[])
{
	for (T i = 0; i < m; ++i)
	{
		ipiv[static_cast<std::size_t>(i)] += 1;
	}
}

template<typename T>
inline T* Clone(const int m, const int n, const T* a)
{
	auto clone = new T[m*n];
	memcpy(clone, a, m*n*sizeof(T));
	return clone;
}

template<typename T>
inline void copyBtoX (int m, int n, int bn, T b[], T x[])
{
	for (auto i = 0; i < n; ++i)
	{
		for (auto j = 0; j < bn; ++j)
		{
			x[j * n + i] = b[j * m + i];
		}
	}
}
