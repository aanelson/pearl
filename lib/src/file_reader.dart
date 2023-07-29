import 'dart:io';

import 'model/buyer.dart';
import 'model/neighborhood.dart';

(List<Buyer>, List<Neighborhood>) parseFile(File file) {
  final List<Buyer> buyers = [];
  final List<Neighborhood> neighborhoods = [];

  for (final line in file.readAsLinesSync()) {
    final splitLine = line.split(' ');
    final type = splitLine.firstOrNull;
    if (type == 'H') {
      buyers.add(_parseBuyer(splitLine));
    } else if (type == 'N') {
      neighborhoods.add(_parseNeighborhood(splitLine));
    } else {
      throw StateError('unknown type expected H or N got $line');
    }
  }
  return (buyers, neighborhoods);
}

Buyer _parseBuyer(List<String> line) {
  if (line.length < 6) {
    throw StateError('home buyer should have length of 6 got $line');
  }
  final parseModel = _parseCommonValues(line);
  final preference = line[5].split('>');

  return Buyer(
    energyEfficiency: parseModel.energyEfficiency,
    water: parseModel.water,
    resilience: parseModel.resilience,
    preference: preference,
    name: parseModel.name,
  );
}

Neighborhood _parseNeighborhood(List<String> line) {
  if (line.length < 5) {
    throw StateError('neighborhood should have length of 5 got $line');
  }
  final parseModel = _parseCommonValues(line);
  return Neighborhood(
    energyEfficiency: parseModel.energyEfficiency,
    water: parseModel.water,
    resilience: parseModel.resilience,
    name: parseModel.name,
  );
}

_CommonParseModel _parseCommonValues(List<String> line) {
  int? energyEfficiency;
  int? water;
  int? resilience;

  for (final item in line) {
    if (item.startsWith('E')) {
      energyEfficiency = int.parse(item.split(':').last);
    } else if (item.startsWith('W')) {
      water = int.parse(item.split(':').last);
    } else if (item.startsWith('R')) {
      resilience = int.parse(item.split(':').last);
    }
  }

  return _CommonParseModel(
    energyEfficiency: energyEfficiency!,
    water: water!,
    resilience: resilience!,
    name: line[1],
  );
}

//todo map
class _CommonParseModel {
  const _CommonParseModel({
    required this.energyEfficiency,
    required this.water,
    required this.resilience,
    required this.name,
  });
  final int energyEfficiency;
  final int water;
  final int resilience;
  final String name;
}
