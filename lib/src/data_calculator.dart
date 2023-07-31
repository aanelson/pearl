import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:pearl/src/file_reader.dart';
import 'package:pearl/src/model/neighborhood.dart';

import 'model/buyer.dart';

class NeighborhoodWithScore extends Equatable {
  NeighborhoodWithScore.fromBuyerAndNeighborhood(
      List<Buyer> buyers, Neighborhood neighborhood)
      : neighborhoodName = neighborhood.name,
        ranking = buyers
            .mapIndexed((i, b) => Ranking(
                name: b.name,
                score: _score(b, neighborhood),
                ranking: b.preference.indexOf(neighborhood.name)))
            .sorted((a, b) => b.score.compareTo(a.score));
  final String neighborhoodName;
  final List<Ranking> ranking;

  @override
  List<Object?> get props => [neighborhoodName, ranking];

  static int _score(Buyer buyer, Neighborhood neighborhood) =>
      buyer.energyEfficiency * neighborhood.energyEfficiency +
      buyer.water * neighborhood.water +
      buyer.resilience * neighborhood.resilience;
}

class BuyerWithScore extends Equatable {
  BuyerWithScore.fromBuyerAndNeighborhood(
      Buyer buyer, List<Neighborhood> neighborhoods)
      : buyerName = buyer.name,
        ranking = neighborhoods
            .mapIndexed((i, n) => Ranking(
                name: n.name,
                score: _score(buyer, n),
                ranking: buyer.preference.indexOf(n.name)))
            .toList();
  final String buyerName;
  final List<Ranking> ranking;

  @override
  List<Object?> get props => [buyerName, ranking];

  static int _score(Buyer buyer, Neighborhood neighborhood) =>
      buyer.energyEfficiency * neighborhood.energyEfficiency +
      buyer.water * neighborhood.water +
      buyer.resilience * neighborhood.resilience;
}

class FlatRanking extends Equatable {
  FlatRanking.fromBuyerAndNeighborhood(Buyer buyer, Neighborhood neighborhood)
      : neighborhoodName = neighborhood.name,
        score = _score(buyer, neighborhood),
        ranking = buyer.preference.indexOf(neighborhood.name),
        buyerName = buyer.name;
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

class Ranking extends Equatable {
  const Ranking({
    required this.name,
    required this.score,
    required this.ranking,
  });
  final String name;
  final int score;
  final int ranking;

  @override
  List<Object?> get props => [name, score, ranking];
}

class DataCalculator {
  const DataCalculator(
    this.output,
    this.file,
  );
  final void Function(String) output;
  final File file;

  void te() {
    final (buyer, neighborhood) = parseFile(file);
    final numberOfBuyers = buyer.length + 1;
    final numberOfNeighborhoods = neighborhood.length + 1;
    // final buyersWithNeighborhoods = buyer
    //     .map((b) => BuyerWithScore.fromBuyerAndNeighborhood(b, neighborhood))
    //     .toList();
    // final neighborhoodWithBuyers = neighborhood
    //     .map((n) => NeighborhoodWithScore.fromBuyerAndNeighborhood(buyer, n))
    //     .toList();
    final flatRanking = buyer
        .expand((element) => neighborhood
            .map((e) => FlatRanking.fromBuyerAndNeighborhood(element, e)))
        .sorted((a, b) => b.score.compareTo(a.score))
        .toList();
    final merge = Merger(numberOfNeighborhoods, flatRanking);
    merge.build();
  }
}

typedef BuyerName = String;
typedef NeighborhoodName = String;

class Merger {
  Merger(this.neighborhoodSize, this.list);
  final int neighborhoodSize;
  final List<FlatRanking> list;
  final Map<NeighborhoodName, List<FlatRanking>> store = {};
  final Map<BuyerName, List<FlatRanking>> addedBuyers = {};

  void build() {
    for (final item in list) {
      final current = store[item.neighborhoodName] ?? [];
      _maybeAdd(item, current);
    }
  }

  void _maybeAdd(FlatRanking ranking, List<FlatRanking> alreadyAddedRankings) {
    print('processing $ranking');
    final currentBuyerAdded = addedBuyers[ranking.buyerName];
    final lockedInValues = alreadyAddedRankings
        .where((element) => element.ranking <= ranking.ranking)
        .length;

    if (alreadyAddedRankings
            .every((element) => element.ranking >= ranking.ranking) &&
        lockedInValues >= neighborhoodSize) {
      return;
    }

    // if (currentBuyerAdded == null) {
    //   _update(ranking);
    //   return;
    // }
    final otherLocations = currentBuyerAdded
            ?.where((element) => element.ranking < ranking.ranking) ??
        [];
    final moreDesiredLocationHasHigherRanking = otherLocations.isNotEmpty;
    if (moreDesiredLocationHasHigherRanking) {
      var earlyReturn = true;
      for (final item in otherLocations) {
        final location = store[item.neighborhoodName]!.indexOf(item) + 1;
        if (location > neighborhoodSize) {
          _remove(item);
          earlyReturn = false;
        }
      }
      if (earlyReturn) {
        return;
      }
    }
    if (lockedInValues < neighborhoodSize) {
      _update(ranking);
    }
  }

  void _update(FlatRanking ranking) {
    final currentBuyerAdded = addedBuyers[ranking.buyerName];
    final lowerRankingInOtherLists = currentBuyerAdded
            ?.where((element) => element.ranking > ranking.ranking)
            .toList() ??
        [];
    print('adding $ranking');
    _add(ranking);
    _remove(lowerRankingInOtherLists.firstOrNull);
  }

  void _remove(FlatRanking? ranking) {
    if (ranking != null) {
      print('removing $ranking');
      store[ranking.neighborhoodName]!.remove(ranking);
    }
    // addedBuyers[ranking.buyerName].remove(ranking);
  }

  void _add(FlatRanking ranking) {
    store.update(
      ranking.neighborhoodName,
      (value) => value..add(ranking),
      ifAbsent: () => [ranking],
    );
    addedBuyers.update(
      ranking.buyerName,
      (value) => value..add(ranking),
      ifAbsent: () => [ranking],
    );
  }
}

class Storage {
  final List<FlatRanking> rankings = [];
  final Set<FlatRanking> lockedInItems = {};
  void _add(FlatRanking ranking, List<Storage> otherStorages) {
    rankings.add(ranking);
  }
  // bool get storeFull => rankings.every((element) => element.ranking ==)
}

/*
[(BuyerWithScore(N0, H0, 104), BuyerWithScore(N1, H0, 17), BuyerWithScore(N2, H0, 83)),
 (BuyerWithScore(N0, H1, 119), BuyerWithScore(N1, H1, 18), BuyerWithScore(N2, H1, 74)),
(BuyerWithScore(N0, H2, 128), BuyerWithScore(N1, H2, 18), BuyerWithScore(N2, H2, 68)), 
(BuyerWithScore(N0, H3, 171), BuyerWithScore(N1, H3, 31), BuyerWithScore(N2, H3, 120)),
 (BuyerWithScore(N0, H4, 122), BuyerWithScore(N1, H4, 23), BuyerWithScore(N2, H4, 106)), 
 (BuyerWithScore(N0, H5, 161), BuyerWithScore(N1, H5, 26), BuyerWithScore(N2, H5, 112)), 
 (BuyerWithScore(N0, H6, 188), BuyerWithScore(N1, H6, 31), BuyerWithScore(N2, H6, 128)), 
 (BuyerWithScore(N0, H7, 106), BuyerWithScore(N1, H7, 20), BuyerWithScore(N2, H7, 75)), 
 (BuyerWithScore(N0, H8, 100), BuyerWithScore(N1, H8, 21), BuyerWithScore(N2, H8, 80)), 
 (BuyerWithScore(N0, H9, 94), BuyerWithScore(N1, H9, 23), BuyerWithScore(N2, H9, 86)), 
 (BuyerWithScore(N0, H10, 120), BuyerWithScore(N1, H10, 21), BuyerWithScore(N2, H10, 86)), 
 (BuyerWithScore(N0, H11, 154), BuyerWithScore(N1, H11, 27), BuyerWithScore(N2, H11, 108))]
*/