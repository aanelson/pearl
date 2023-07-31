import 'package:pearl/src/file_reader.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  test('can parse and give back values', () {
    final (buyers, neighborhoods) = parseFile(testDataFile);
    expect(buyers, hasLength(12));
    expect(neighborhoods, hasLength(3));
  });
}
