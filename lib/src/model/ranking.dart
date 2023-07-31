import 'package:equatable/equatable.dart';

import 'buyer.dart';
import 'neighborhood.dart';

class Ranking extends Equatable {
  Ranking.fromBuyerAndNeighborhood(Buyer buyer, Neighborhood neighborhood)
      : neighborhoodName = neighborhood.name,
        score = _score(buyer, neighborhood),
        ranking = buyer.preference.indexOf(neighborhood.name),
        buyerName = buyer.name;
  const Ranking({
    required this.neighborhoodName,
    required this.buyerName,
    required this.score,
    required this.ranking,
  });
  final String neighborhoodName;
  final String buyerName;
  final int score;
  final int ranking;
  static int _score(Buyer buyer, Neighborhood neighborhood) =>
      buyer.energyEfficiency * neighborhood.energyEfficiency +
      buyer.water * neighborhood.water +
      buyer.resilience * neighborhood.resilience;

  @override
  List<Object?> get props => [neighborhoodName, buyerName, score, ranking];
}
