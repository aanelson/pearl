import 'package:pearl/src/calculate_neighborhood_with_buyer.dart';
import 'package:pearl/src/file_reader.dart';
import 'package:pearl/src/model/ranking.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  test('parse function sorts items correctly', () {
    final (buyers, neighborhoods) = parseFile(testDataFile);

    final calc = calculateNeighborhoodWithBuyer(neighborhoods, buyers);

    expect(calc['N0'], [
      _ranking(buyerName: 'H5', score: 161),
      _ranking(buyerName: 'H11', score: 154),
      _ranking(buyerName: 'H2', score: 128),
      _ranking(buyerName: 'H4', score: 122),
    ]);
    expect(calc['N1'], [
      _ranking(buyerName: 'H9', score: 23),
      _ranking(buyerName: 'H8', score: 21),
      _ranking(buyerName: 'H7', score: 20),
      _ranking(buyerName: 'H1', score: 18),
    ]);
    expect(calc['N2'], [
      _ranking(buyerName: 'H6', score: 128),
      _ranking(buyerName: 'H3', score: 120),
      _ranking(buyerName: 'H10', score: 86),
      _ranking(buyerName: 'H0', score: 83),
    ]);
  });
}

TypeMatcher<Ranking> _ranking(
        {required String buyerName, required int score}) =>
    TypeMatcher<Ranking>()
        .having((p0) => p0.score, 'score', score)
        .having((p0) => p0.buyerName, 'name', buyerName);
