import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart';

class MainBloc {
  late List<String> code;
  late int position;
  late int codePointer;
  late List<int> tape;
  late List<int> bracketStack;
  late List<String> input;
  late List<String> output;
  final bool debug;
  
  // Create a logger for this class
  final Logger _logger = Logger('MainBloc');

  // Use late final for subjects
  late final BehaviorSubject<int> _position;
  late final BehaviorSubject<List<int>> _tape;
  late final BehaviorSubject<List<String>> _output;
  late final BehaviorSubject<double> delay;
  late final BehaviorSubject<bool> _isStopped;

  // Stream getters
  Stream<int> get positionStream => _position.stream;
  Stream<List<int>> get tapeStream => _tape.stream;
  Stream<List<String>> get composingOutput => _output.stream;
  Stream<bool> get isStopped => _isStopped.stream;

  MainBloc({this.debug = true, double delayValue = 100}) {
    // Initialize logging
    Logger.root.level = debug ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      // We'll use print here as the lowest level output mechanism
      // In a real app, you might use a more sophisticated approach
      if (debug || record.level >= Level.INFO) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
    });

    delay = BehaviorSubject<double>.seeded(delayValue);
    _isStopped = BehaviorSubject<bool>.seeded(false);
    _position = BehaviorSubject<int>.seeded(0);
    _tape = BehaviorSubject<List<int>>.seeded([0]);
    _output = BehaviorSubject<List<String>>.seeded([]);
    _reset();

    if (debug) {
      delay.listen((event) {
        _logger.fine('Delay changed to: $event');
      });
    }
  }

  Future<void> operation(String str) async {
    switch (str) {
      case '+':
        {
          await add();
          break;
        }

      case '-':
        {
          await subtract();
          break;
        }

      case '<':
        {
          await shiftLeft();
          break;
        }

      case '>':
        {
          await shiftRight();
          break;
        }

      case '.':
        {
          await printValue();
          break;
        }

      case ',':
        {
          if (input.isNotEmpty) {
            var c = input.removeAt(0);
            tape[position] = c.codeUnitAt(0);
          } else {
            _logger.warning('Attempted to read input but none available');
            tape[position] = 0; // Set to 0 or another default value
          }
          break;
        }

      case '[':
        {
          leftBracket();

          if (debug) {
            _logger.fine('Starting a loop');
          }
          break;
        }

      case ']':
        {
          rightBracket();

          if (debug) {
            _logger.fine('Ending a loop');
          }
          break;
        }

      default:
        {
          _logger.severe('Invalid character: $str');
          throw Exception('Invalid character: $str');
        }
    }
  }

  Future<void> add() async {
    // Ensure the tape has enough cells
    while (tape.length <= position) {
      tape.add(0);
    }
    
    ++tape[position];
    _tape.sink.add(tape);
    await Future.delayed(Duration(milliseconds: delay.value.toInt()));

    if (debug) {
      _logger.fine('Incrementing > ${tape[position]} at $position');
    }
  }

  Future<void> subtract() async {
    try {
      --tape[position];
    } catch (e) {
      // Extend the tape if position is out of bounds
      while (tape.length <= position) {
        tape.add(0);
      }
      tape[position] = -1; // -1 since we're subtracting from 0
    }
    await Future.delayed(Duration(milliseconds: delay.value.toInt()));
    _tape.sink.add(tape);

    if (debug) {
      _logger.fine('Decrementing > ${tape[position]} at $position');
    }
  }

  Future<void> shiftLeft() async {
    position = --position < 0 ? 0 : position;

    await Future.delayed(Duration(milliseconds: delay.value.toInt()));
    _position.sink.add(position);
    if (debug) {
      _logger.fine('Going left to $position');
    }
  }

  Future<void> shiftRight() async {
    position++;

    // Extend the tape if necessary
    if (tape.length <= position) {
      tape.add(0);
      _tape.sink.add(tape);
    }
    
    await Future.delayed(Duration(milliseconds: delay.value.toInt()));
    _position.sink.add(position);
    
    if (debug) {
      _logger.fine('Going right to $position');
    }
  }

  Future<void> printValue() async {
    output.add(String.fromCharCode(tape[position]));
    _output.sink.add(output);

    if (debug) {
      _logger.fine('Printing ${tape[position]} at $position');
    }
  }

  void leftBracket() {
    var openBrackets = 1;
    if (tape[position] > 0) {
      bracketStack.add(codePointer);
      _logger.fine('Adding bracket at position $codePointer to stack');
    } else {
      _logger.fine('Skipping loop at position $codePointer');
      while (openBrackets > 0 && ++codePointer < code.length) {
        if (code[codePointer] == ']') {
          openBrackets--;
        } else if (code[codePointer] == '[') {
          openBrackets++;
        }
      }
    }
  }

  void rightBracket() {
    if (bracketStack.isEmpty) {
      _logger.warning('Unmatched closing bracket at position $codePointer');
      return; // Skip this bracket if there's no matching opening bracket
    }
    codePointer = bracketStack.removeLast() - 1;
    _logger.fine('Jumping back to position ${codePointer + 1}');
  }

  Future<String> run(String code) async {
    _logger.info('Starting BrainDart execution');
    _reset();
    this.code =
        code.replaceAll(RegExp(r"[\dA-Za-z\r\n/# '()\\]"), '').trim().split('');
    
    // Check if code is empty after filtering
    if (this.code.isEmpty) {
      _logger.warning('No valid BrainF code to run');
      return '';
    }
    
    var list = <String>['+', '-', '<', '>', '.', ',', '[', ']'];
    do {
      var c = this.code[codePointer];
      if (list.contains(c)) {
        if (debug) {
          _logger.fine('Operation: $c');
        }
        await operation(c);
      }
    } while (++codePointer < this.code.length && !_isStopped.value);

    var result = output.join('');
    if (!_isStopped.value) {
      _reset();
      _logger.info('Execution completed successfully');
    } else {
      _logger.info('Execution stopped by user');
    }
    return result;
  }

  void stop() {
    _logger.info('Stopping execution');
    _isStopped.add(true);
  }

  void _reset() {
    code = [];
    input = [];
    position = 0;
    codePointer = 0;
    tape = [0];  // Initialize with a 0 to match constructor
    bracketStack = [];
    output = [];
    _isStopped.add(false);
    _tape.sink.add(tape);  // Update the tape subject
    _position.sink.add(position);  // Update the position subject
    _logger.fine('Reset all variables to initial state');
  }

  // Add dispose method to clean up resources
  void dispose() {
    _logger.info('Disposing resources');
    _position.close();
    _tape.close();
    _output.close();
    delay.close();
    _isStopped.close();
  }
}

String BF_HELLO_WORLD = '''
+++++ +++++             initialize counter (cell #0) to 10
[                       use loop to set 70/100/30/10
    > +++++ ++              add  7 to cell #1
    > +++++ +++++           add 10 to cell #2
    > +++                   add  3 to cell #3
    > +                     add  1 to cell #4
<<<< -                  decrement counter (cell #0)
]
> ++ .                  print 'H'
> + .                   print 'e'
+++++ ++ .              print 'l'
.                       print 'l'
+++ .                   print 'o'
> ++ .                  print ' '
<< +++++ +++++ +++++ .  print 'W'
> .                     print 'o'
+++ .                   print 'r'
----- - .               print 'l'
----- --- .             print 'd'
> + .                   print '!'
''';
