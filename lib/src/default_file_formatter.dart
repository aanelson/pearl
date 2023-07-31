import 'calculate_neighborhood_with_buyer.dart';

List<String> defaultFileformatter(NeighborhoodsWithBuyers rankings) {
  final display = <String>[];
  rankings.forEach((key, value) {
    final buyers = value.map((e) => '${e.buyerName}(${e.score})').join(' ');
    display.add('$key: $buyers');
  });
  return display;
}
