import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mar_floppy_manager/mar_floppy_manager.dart';

Future<int> main(List<String> args) async {
  final runner = new CommandRunner('mar_floppy_manager', 'A tool for working with MAR floppy media.')
    ..addCommand(CreateCommand())
    ..addCommand(ReadCommand())
    ..addCommand(WriteCommand());

  try {
    await runner.run(args);

    return 0;
  } on UsageException catch (ex) {
    print(ex.message);
    return 1;
  }
}