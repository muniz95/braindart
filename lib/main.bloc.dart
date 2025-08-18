import 'package:rxdart/rxdart.dart';

class MainBloc {
  late List<String> code;
  late int position;
  late int codePointer;
  late List<int> tape;
  late List<int> bracketStack;
  late List<String> input;
  late List<String> output;
  final bool debug;

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
    delay = BehaviorSubject<double>.seeded(delayValue);
    _isStopped = BehaviorSubject<bool>.seeded(false);
    _position = BehaviorSubject<int>.seeded(0);
    _tape = BehaviorSubject<List<int>>.seeded([0]);
    _output = BehaviorSubject<List<String>>.seeded([]);
    _reset();

    if (debug) {
      delay.listen((event) {
        print('Delay changed to: $event');
      });
    }
  }

  Future operation(str) async {
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
          var c = input.removeAt(0);
          tape[position] = c.codeUnitAt(0);
          break;
        }

      case '[':
        {
          leftBracket();

          if (debug) {
            print('Starting a loop');
          }
          break;
        }

      case ']':
        {
          rightBracket();

          if (debug) {
            print('Ending a loop');
          }
          break;
        }

      default:
        {
          throw Exception('Invalid character');
        }
    }
  }

  Future add() async {
    try {
      tape[position] = tape[position];
    } catch (e) {
      tape.add(0);
    }
    ++tape[position];
    _tape.sink.add(tape);
    await Future.delayed(Duration(milliseconds: delay.value.toInt()));

    if (debug) {
      print('Incrementing > ${tape[position]} at $position');
    }
  }

  Future subtract() async {
    try {
      tape[position] = tape[position];
    } catch (e) {
      tape.add(0);
    }
    await Future.delayed(Duration(milliseconds: delay.value.toInt()));
    _tape.sink.add(tape);
    --tape[position];

    if (debug) {
      print('Decrementing > ${tape[position]} at $position');
    }
  }

  Future shiftLeft() async {
    position = --position < 0 ? 0 : position;

    await Future.delayed(Duration(milliseconds: delay.value.toInt()));
    _position.sink.add(position);
    if (debug) {
      print('Going left to $position');
    }
  }

  Future shiftRight() async {
    position++;

    if (tape.length > position) {
      await Future.delayed(Duration(milliseconds: delay.value.toInt()));
      _position.sink.add(position);
    }
    if (debug) {
      print('Going right to $position');
    }
  }

  Future printValue() async {
    output.add(String.fromCharCode(tape[position]));
    _output.sink.add(output);

    if (debug) {
      print('Printing ${tape[position]} at $position');
    }
  }

  void leftBracket() {
    var openBrackets = 1;
    if (tape[position] > 0) {
      bracketStack.add(codePointer);
    } else {
      while (openBrackets > 0) {
        if (code[codePointer] == ']') {
          openBrackets--;
        } else if (code[codePointer] == '[') {
          openBrackets++;
        }
      }
    }
  }

  void rightBracket() {
    codePointer = bracketStack.removeLast() - 1;
  }

  Future<String> run(String code) async {
    _reset();
    this.code =
        code.replaceAll(RegExp(r"[\dA-Za-z\r\n/# '()\\]"), '').trim().split('');
    var list = <String>['+', '-', '<', '>', '.', ',', '[', ']'];
    do {
      var c = this.code[codePointer];
      if (list.contains(c)) {
        if (debug) {
          print('Operation: $c');
        }
        await operation(c);
      }
    } while (++codePointer < this.code.length && !_isStopped.value);

    var result = output.join('');
    if (!_isStopped.value) {
      _reset();
    }
    return result;
  }

  void stop() {
    _isStopped.add(true);
  }

  void _reset() {
    code = [];
    input = [];
    position = 0;
    codePointer = 0;
    tape = [];
    bracketStack = [];
    output = [];
    _isStopped.add(false);
  }

  // Add dispose method to clean up resources
  void dispose() {
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
