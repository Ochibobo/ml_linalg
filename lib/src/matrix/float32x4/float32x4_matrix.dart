import 'dart:collection';
import 'dart:core';
import 'dart:typed_data';

import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/src/matrix/float32x4/float32_data_helper_mixin.dart';
import 'package:ml_linalg/src/matrix/float32x4/float32_matrix_iterator.dart';
import 'package:ml_linalg/src/matrix/matrix_fast_iterable_mixin.dart';
import 'package:ml_linalg/src/matrix/matrix_mixin.dart';
import 'package:ml_linalg/src/matrix/matrix_validator_mixin.dart';
import 'package:ml_linalg/vector.dart';

class Float32x4Matrix with
        IterableMixin<Iterable<double>>,
        MatrixValidatorMixin,
        Float32DataHelperMixin,
        MatrixFastIterableMixin,
        MatrixMixin
    implements Matrix {

  Float32x4Matrix.from(Iterable<Iterable<double>> source)
      : rowsNum = source.length,
        columnsNum = source.first.length,
        data = ByteData(
            source.length * source.first.length * Float32List.bytesPerElement),
        rowsCache = List<Vector>(source.length),
        columnsCache = List<Vector>(source.first.length) {
    final flattened = flatten2dimList(source, (i, j) => i * columnsNum + j);
    data.buffer.asFloat32List().setAll(0, flattened);
  }

  /// vectors from [source] will serve as columns of the matrix
  /// It works this way:
  /// Input:
  /// ```
  ///   {a1 a2 a3 a4}
  ///   {b1 b2 b3 b4}
  ///   {c1 c2 c3 c4}
  ///```
  ///  Output:
  /// ```
  ///   {a1} {b1} {c1}
  ///   {a2} {b2} {c2}
  ///   {a3} {b3} {c3}
  ///   {a4} {b4} {c4}
  /// ```
  Float32x4Matrix.columns(Iterable<Vector> source)
      : rowsNum = source.first.length,
        columnsNum = source.length,
        data = ByteData(
            source.length * source.first.length * Float32List.bytesPerElement),
        rowsCache = List<Vector>(source.first.length),
        columnsCache = source.toList(growable: false) {
    // TODO: try to set the source values right in the byte data buffer
    // inside `flatten2dimList` method
    final flattened = flatten2dimList(source, (i, j) => j * columnsNum + i);
    data.buffer.asFloat32List().setAll(0, flattened);
  }

  /// vectors from [source] will serve as rows of the matrix
  Float32x4Matrix.rows(Iterable<Vector> source)
      : rowsNum = source.length,
        columnsNum = source.first.length,
        data = ByteData(
            source.length * source.first.length * Float32List.bytesPerElement),
        rowsCache = source.toList(growable: false),
        columnsCache = List<Vector>(source.first.length) {
    // TODO: try to set the source values right in the byte data buffer
    // inside `flatten2dimList` method
    final flattened = flatten2dimList(source, (i, j) => i * columnsNum + j);
    data.buffer.asFloat32List().setAll(0, flattened);
  }

  Float32x4Matrix.flattened(
      Iterable<double> source, this.rowsNum, this.columnsNum)
      : data = ByteData(rowsNum * columnsNum * Float32List.bytesPerElement),
        rowsCache = List<Vector>(rowsNum),
        columnsCache = List<Vector>(columnsNum) {
    if (source.length != rowsNum * columnsNum) {
      throw Exception('Invalid matrix dimension is provided');
    }
    data.buffer.asFloat32List().setAll(0, source);
  }

  @override
  final Type dtype = Float32x4;

  @override
  final int rowsNum;

  @override
  final int columnsNum;

  @override
  final ByteData data;

  @override
  final List<Vector> columnsCache;

  @override
  final List<Vector> rowsCache;

  @override
  Iterator<Iterable<double>> get iterator =>
      Float32MatrixIterator(data, columnsNum);
}