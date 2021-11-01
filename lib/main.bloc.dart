import 'package:rxdart/rxdart.dart';

class MainBloc {
  List<String> code;
  int position;
  BehaviorSubject<int> _position;
  int codePointer;
  List<int> tape;
  BehaviorSubject<List<int>> _tape;
  List<int> bracketStack;
  List<String> input;
  List<String> output;
  BehaviorSubject<List<String>> _output;
  bool debug;
  BehaviorSubject<double> delay;
  BehaviorSubject<bool> _isStopped;

  Stream<int> get positionStream => _position.stream;
  Stream<List<int>> get tapeStream => _tape.stream;
  Stream<List<String>> get composingOutput => _output.stream;
  Stream<bool> get isStopped => _isStopped.stream;

  MainBloc({bool debug = false, double delay = 100}) {
    this.debug = debug;
    this.delay = BehaviorSubject<double>.seeded(delay);
    _isStopped = BehaviorSubject<bool>.seeded(false);
    _position = BehaviorSubject<int>.seeded(0);
    _tape = BehaviorSubject<List<int>>.seeded([0]);
    _output = BehaviorSubject<List<String>>.seeded([]);
    _reset();

    if (debug) {
      this.delay.listen((event) {
        print(event);
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
    if (tape[position] != null && tape[position] > 0) {
      bracketStack.add(codePointer);
    } else {
      while (openBrackets > 0 && code[++codePointer] != null) {
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
