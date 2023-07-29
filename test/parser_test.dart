import 'dart:io';

import 'package:pearl/src/file_reader.dart';
import 'package:test/test.dart';

void main() {
  test('can parse and give back values', () {
    final file = File('test/testdata');
    final (buyers, neighborhoods) = parseFile(file);
    expect(buyers, hasLength(12));
    expect(neighborhoods, hasLength(3));
  });
}
