import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pearl/src/model/buyer.dart';

import 'model/neighborhood.dart';
import 'model/ranking.dart';

typedef BuyerName = String;
typedef NeighborhoodName = String;
typedef NeighborhoodsWithBuyers = Map<NeighborhoodName, List<Ranking>>;

class CalculateNeighborhoodWithBuyer {
  const CalculateNeighborhoodWithBuyer(
    this.neighborhoods,
    this.buyers,
  );
  final List<Neighborhood> neighborhoods;
  final List<Buyer> buyers;
}

NeighborhoodsWithBuyers calculateNeighborhoodWithBuyer(
    List<Neighborhood> neighborhoods, List<Buyer> buyers) {
  final numberOfNeighborhoods = neighborhoods.length + 1;

  final flatRanking = buyers
      .expand((element) => neighborhoods
          .map((e) => Ranking.fromBuyerAndNeighborhood(element, e)))
      .sorted((a, b) => b.score.compareTo(a.score))
      .toList();
  _workDone(5);
  final merge =
      _CalculateNeighborhoodWithBuyer(numberOfNeighborhoods, flatRanking);
  return merge.build();
}

void _workDone(double time) {}

class _CalculateNeighborhoodWithBuyer {
  _CalculateNeighborhoodWithBuyer(
    this.neighborhoodSize,
    this.list,
  );
  final int neighborhoodSize;
  final List<Ranking> list;
  final Storage _storage = Storage();

  NeighborhoodsWithBuyers build() {
    for (final (i, item) in list.indexed) {
      sleep(Duration(milliseconds: 25));
      _workDone(i / list.length);
      _maybeAdd(item);
    }
    return _storage.store;
  }

  void _maybeAdd(Ranking ranking) {
    if (_allRankingsHigherAndNeighborhoodIsFull(ranking)) {
      return;
    }

    final otherLocations = _storage.otherLocationsProcessedForBuyer(ranking);
    final moreDesiredLocationHasHigherRanking = otherLocations.isNotEmpty;
    if (moreDesiredLocationHasHigherRanking) {
      var earlyReturn = true;
      for (final item in otherLocations) {
        final location = _storage.locationOfItemInNeighborhood(item)!;
        if (location > neighborhoodSize) {
          _storage.remove(item);
          earlyReturn = false;
        }
      }
      if (earlyReturn) {
        return;
      }
    }

    final alreadyAddedRankings =
        _storage.listOfCurrentRankingForLocation(ranking);

    final lockedInValues = alreadyAddedRankings
        .where((element) => element.ranking <= ranking.ranking)
        .length;

    if (lockedInValues < neighborhoodSize) {
      _storage.update(ranking);
    }
  }

  bool _allRankingsHigherAndNeighborhoodIsFull(Ranking ranking) {
    final alreadyAddedRankings =
        _storage.listOfCurrentRankingForLocation(ranking);

    final lockedInValues = alreadyAddedRankings
        .where((element) => element.ranking <= ranking.ranking)
        .length;
    final allRankingsHigher = alreadyAddedRankings
        .every((element) => element.ranking >= ranking.ranking);
    return allRankingsHigher && lockedInValues >= neighborhoodSize;
  }
}

class Storage {
  final Map<NeighborhoodName, List<Ranking>> store = {};
  final Map<BuyerName, List<Ranking>> addedBuyers = {};

  Iterable<Ranking> otherLocationsProcessedForBuyer(Ranking ranking) =>
      addedBuyers[ranking.buyerName]
          ?.where((element) => element.ranking < ranking.ranking) ??
      [];
  List<Ranking> listOfCurrentRankingForLocation(Ranking item) =>
      store[item.neighborhoodName] ?? [];

  int? locationOfItemInNeighborhood(Ranking item) {
    final index = store[item.neighborhoodName]?.indexOf(item);
    if (index == null) {
      return null;
    }
    return index + 1;
  }

  void update(Ranking ranking) {
    final currentBuyerAdded = addedBuyers[ranking.buyerName];
    final lowerRankingInOtherLists = currentBuyerAdded
            ?.where((element) => element.ranking > ranking.ranking)
            .toList() ??
        [];
    _add(ranking);
    remove(lowerRankingInOtherLists.firstOrNull);
  }

  void remove(Ranking? ranking) {
    if (ranking != null) {
      store[ranking.neighborhoodName]!.remove(ranking);
    }
  }

  void _add(Ranking ranking) {
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
