import 'package:pearl/src/default_file_formatter.dart';
import 'package:pearl/src/model/ranking.dart';
import 'package:test/test.dart';

void main() {
  test('test formatting of items', () {
    final format = defaultFileformatter({
      'N0': [
        Ranking(neighborhoodName: 'N0', buyerName: 'H5', score: 99, ranking: 0),
        Ranking(neighborhoodName: 'N0', buyerName: 'H2', score: 44, ranking: 0)
      ]
    });
    expect(format, ['N0: H5(99) H2(44)']);
  });
}
