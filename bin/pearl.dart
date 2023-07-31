import 'dart:io';

import 'package:args/args.dart';
import 'package:pearl/pearl.dart' as pearl;
import 'package:pearl/src/calculate_neighborhood_with_buyer.dart';
import 'package:pearl/src/file_reader.dart';

const input = 'input';
const output = 'output';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(input, abbr: 'i', help: 'file input for parsing')
    ..addOption(output, abbr: 'o', defaultsTo: output);
  final results = parser.parse(arguments);
  final filepath = results[input];
  final file = File(filepath);
  if (file.existsSync()) {
    final (buyers, neighborhoods) = parseFile(file);
    final result = calculateNeighborhoodWithBuyer(neighborhoods, buyers);
  } else {
    exitCode = 2;
  }
  // print('Hello world: ${pearl.calculate()}!');
}
