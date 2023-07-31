import 'dart:io';

import 'package:args/args.dart';
import 'package:pearl/src/calculate_neighborhood_with_buyer.dart';
import 'package:pearl/src/default_file_formatter.dart';
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
    final formattedData = defaultFileformatter(result);
    final writeFile = File(results[output]);
    writeFile.writeAsStringSync(formattedData);
  } else {
    exitCode = 2;
  }
}
