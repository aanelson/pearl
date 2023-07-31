import 'package:collection/collection.dart';

import 'calculate_neighborhood_with_buyer.dart';

String defaultFileformatter(NeighborhoodsWithBuyers rankings) {
  final sortedKeys = rankings.keys.sorted((a, b) => a.compareTo(b));
  final display = sortedKeys.map((e) {
    final buyers =
        rankings[e]!.map((e) => '${e.buyerName}(${e.score})').join(' ');
    return '$e: $buyers';
  });

  return display.join('\n');
}
