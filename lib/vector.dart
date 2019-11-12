import 'dart:typed_data';

import 'package:ml_linalg/distance.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/norm.dart';
import 'package:ml_linalg/src/common/cache_manager/cache_manager_factory.dart';
import 'package:ml_linalg/src/di/dependencies.dart';
import 'package:ml_linalg/src/vector/float32x4_vector.dart';
import 'package:ml_linalg/src/vector/float64x2_vector.gen.dart';
import 'package:ml_linalg/src/vector/simd_helper/simd_helper_factory.dart';

final _cacheManagerFactory = dependencies.getDependency<CacheManagerFactory>();
final _simdHelperFactory = dependencies.getDependency<SimdHelperFactory>();

/// An algebraic vector with SIMD (single instruction, multiple data)
/// architecture support
///
/// The vector's components are represented by special data type, that allows
/// to perform vector operations extremely fast due to hardware assisted
/// computations.
abstract class Vector implements Iterable<double> {
  /// Creates a vector from a [source].
  ///
  /// A usage example:
  ///
  /// ````dart
  /// import 'package:ml_linalg/vector.dart';
  ///
  /// final vector = Vector.fromList([1, 2, 3, 4, 5], dtype: DType.float32);
  ///
  /// print(vector);
  /// ````
  ///
  /// the output will be like that:
  ///
  /// ```
  /// (1.0, 2.0, 3.0, 4.0, 5.0)
  /// ```
  factory Vector.fromList(List<num> source, {
    DType dtype = DType.float32,
  }) {
    switch (dtype) {
      case DType.float32:
        return Float32x4Vector.fromList(source, _cacheManagerFactory.create(),
            _simdHelperFactory.createByDType(dtype));

      case DType.float64:
        return Float64x2Vector.fromList(source, _cacheManagerFactory.create(),
            _simdHelperFactory.createByDType(dtype));

      default:
        throw UnimplementedError('Vector of $dtype type is not implemented yet');
    }
  }

  /// Creates a vector from a simd-typed collection. It accepts only
  /// [Float32x4List] or [Float64x2List] lists as a source.
  ///
  /// A usage example:
  ///
  /// ````dart
  /// import 'dart:typed_data';
  /// import 'package:ml_linalg/vector.dart';
  ///
  /// final source1 = Float64x2List.fromList([1, 2, 3, 4, 5]);
  /// final source2 = Float32x4List.fromList([1, 2, 3, 4, 5]);
  ///
  /// final vector1 = Vector.fromSimdList(source1, dtype: DType.float64);
  /// final vector2 = Vector.fromSimdList(source2, dtype: DType.float32);
  ///
  /// print(vector1);
  /// print(vector2);
  /// ````
  ///
  /// the output will be like that:
  ///
  /// ```
  /// (1.0, 2.0, 3.0, 4.0, 5.0)
  /// (1.0, 2.0, 3.0, 4.0, 5.0)
  /// ```
  factory Vector.fromSimdList(List source, int actualLength, {
    DType dtype = DType.float32,
  }) {
    switch (dtype) {
      case DType.float32:
        return Float32x4Vector.fromSimdList(
          source as Float32x4List,
          actualLength,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
        );

      case DType.float64:
        return Float64x2Vector.fromSimdList(
          source as Float64x2List,
          actualLength,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
        );

      default:
        throw UnimplementedError('Vector of $dtype type is not implemented yet');
    }
  }

  /// Creates a vector of length equal to [length] filled with [value].
  ///
  /// A usage example:
  ///
  /// ````dart
  /// import 'package:ml_linalg/vector.dart';
  ///
  /// final vector = Vector.filled(5, 2, dtype: DType.float32);
  ///
  /// print(vector);
  /// ````
  ///
  /// the output will be like that:
  ///
  /// ```
  /// (2.0, 2.0, 2.0, 2.0, 2.0)
  /// ```
  factory Vector.filled(int length, num value, {
    DType dtype = DType.float32,
  }) {
    switch (dtype) {
      case DType.float32:
        return Float32x4Vector.filled(
          length,
          value,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
        );

      case DType.float64:
        return Float64x2Vector.filled(
          length,
          value,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
        );

      default:
        throw UnimplementedError('Vector of $dtype type is not implemented yet');
    }
  }

  /// Creates a vector filled with zeroes with length equal to [length].
  ///
  /// A usage example:
  ///
  /// ````dart
  /// import 'package:ml_linalg/vector.dart';
  ///
  /// final vector = Vector.zero(5, dtype: DType.float32);
  ///
  /// print(vector);
  /// ````
  ///
  /// the output will be like that:
  ///
  /// ```
  /// (0.0, 0.0, 0.0, 0.0, 0.0)
  /// ```
  factory Vector.zero(int length, {
    DType dtype = DType.float32,
  }) {
    switch (dtype) {
      case DType.float32:
        return Float32x4Vector.zero(
          length,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
        );

      case DType.float64:
        return Float64x2Vector.zero(
          length,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
        );

      default:
        throw UnimplementedError('Vector of $dtype type is not implemented yet');
    }
  }

  /// Creates a vector of length equal to [length], filled with random
  /// values within the range [min] (inclusive) - [max] (exclusive). If [min]
  /// greater than or equal to [max] - an argument error will be thrown. The
  /// random values are generated by [Random] class instance, that is created
  /// with a seed value equals [seed]
  ///
  /// A usage example:
  ///
  /// ````dart
  /// import 'package:ml_linalg/vector.dart';
  ///
  /// final vector = Vector.randomFilled(5, seed: 1, min: -5, max: -1,
  ///   dtype: DType.float64);
  ///
  /// print(vector);
  /// ````
  ///
  /// the output will be like that:
  ///
  /// ```
  /// (-2.6859948542351675, -3.977462789496658, -1.3201339513128914, -1.2556185255852372, -3.254262886438903)
  /// ```
  factory Vector.randomFilled(int length, {
    int seed = 1,
    num min = 0,
    num max = 1,
    DType dtype = DType.float32,
  }) {
    switch (dtype) {
      case DType.float32:
        return Float32x4Vector.randomFilled(
          length,
          seed,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
          max: max,
          min: min,
        );

      case DType.float64:
        return Float64x2Vector.randomFilled(
          length,
          seed,
          _cacheManagerFactory.create(),
          _simdHelperFactory.createByDType(dtype),
          max: max,
          min: min,
        );

      default:
        throw UnimplementedError('Vector of $dtype type is not implemented yet');
    }
  }

  /// Creates a vector of zero length
  ///
  /// A usage example:
  ///
  /// ````dart
  /// import 'package:ml_linalg/vector.dart';
  ///
  /// final vector = Vector.empty(dtype: DType.float32);
  ///
  /// print(vector);
  /// ````
  ///
  /// the output will be like that:
  ///
  /// ```
  /// ()
  /// ```
  factory Vector.empty({DType dtype = DType.float32}) {
    switch (dtype) {
      case DType.float32:
        return Float32x4Vector.empty(_cacheManagerFactory.create(),
            _simdHelperFactory.createByDType(dtype));

      case DType.float64:
        return Float64x2Vector.empty(_cacheManagerFactory.create(),
            _simdHelperFactory.createByDType(dtype));

      default:
        throw UnimplementedError('Vector of $dtype type is not implemented yet');
    }
  }

  /// Denotes a data type, used for representation of the vector's elements
  DType get dtype;

  /// Returns an element by its index in the vector
  double operator [](int index);

  /// Element-wise addition
  Vector operator +(Object value);

  /// Element-wise subtraction
  Vector operator -(Object value);

  /// Element-wise multiplication
  Vector operator *(Object value);

  /// Element-wise division
  Vector operator /(Object value);

  /// Returns a new [Vector] consisting of square roots of elements of this
  /// [Vector]
  Vector sqrt({bool skipCaching = false});

  /// Returns a new [Vector] where elements are the elements from this [Vector]
  /// divided by [scalar]
  Vector scalarDiv(num scalar);

  /// Creates a new [Vector] containing elements of this [Vector] raised to
  /// the integer [power]
  Vector toIntegerPower(int power);

  /// Returns a new vector where the elements are absolute values of the
  /// original vector's elements
  Vector abs({bool skipCaching = false});

  /// Returns a dot (inner) product of [this] and [vector]
  double dot(Vector vector);

  /// Returns a distance between [this] and [vector]
  double distanceTo(Vector vector, {
    Distance distance = Distance.euclidean,
  });

  /// Returns cosine of the angle between [this] and [other] vector
  double getCosine(Vector other);

  /// Returns a mean value of [this] vector
  double mean({bool skipCaching = false});

  /// Calculates vector norm (magnitude)
  double norm([Norm norm = Norm.euclidean, bool skipCaching = false]);

  /// Returns sum of all vector elements
  double sum({bool skipCaching = false});

  /// Returns maximum element among the all vector elements
  double max({bool skipCaching = false});

  /// Returns maximum element among the all vector elements
  double min({bool skipCaching = false});

  /// Returns a new vector composed of elements which are located on the passed
  /// indexes
  Vector sample(Iterable<int> indices);

  /// Returns a new vector composed of the vector's unique elements
  Vector unique({bool skipCaching = false});

  /// Returns a new vector with normalized values of [this] vector
  Vector normalize([Norm norm = Norm.euclidean, bool skipCaching = false]);

  /// Returns rescaled (min-max normed) version of this vector
  Vector rescale({bool skipCaching = false});

  /// Returns a new vector from mapped elements of the original vector.
  /// Mapping function [mapper] should accept argument only of [Float32x4] or
  /// [Float64x2] data type (depends on [dtype] value, e.g. if [dtype] equals
  /// [DType.float32] - the argument should be of [Float32x4] type). The data
  /// types mentioned above allow to perform mapping much faster comparing with
  /// the regular [map] method
  Vector fastMap<T>(T mapper(T element));

  /// Returns a new vector composed of values which indices are within the range
  /// [start] (inclusive) - [end] (exclusive)
  Vector subvector(int start, [int end]);
}
