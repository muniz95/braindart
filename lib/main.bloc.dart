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
  int delay;

  Stream<int> get positionStream => _position.stream;
  Stream<List<int>> get tapeStream => _tape.stream;
  Stream<List<String>> get composingOutput => _output.stream;

  MainBloc({bool debug = false, int delay = 100}) {
    _reset();
    this.debug = debug;
    this.delay = delay;
    this._position = BehaviorSubject<int>.seeded(0);
    this._tape = BehaviorSubject<List<int>>.seeded([0]);
    this._output = BehaviorSubject<List<String>>.seeded([]);
  }

  Future operation(str) async {
    switch (str) {
      case '+': {
        await add();
        break;
      }

      case '-': {
        await subtract();
        break;
      }

      case '<': {
        await shiftLeft();
        break;
      }

      case '>': {
        await shiftRight();
        break;
      }

      case '.': {
        await printValue();
        break;
      }

      case ',': {
        String c = this.input.removeAt(0);
        this.tape[this.position] = c.codeUnitAt(0);
        break;
      }

      case '[': {
        this.leftBracket();

        if (this.debug) {
          print('Starting a loop');
        }
        break;
      }

      case ']': {
        this.rightBracket();

        if (this.debug) {
          print('Ending a loop');
        }
        break;
      }

      default: {
        throw Exception('Invalid character');
      }
    }

  }

  Future add() async {
    try {
      this.tape[this.position] = this.tape[this.position];
    } catch (e) {
      this.tape.add(0);
    }
    ++this.tape[this.position];
    _tape.sink.add(this.tape);
    await Future.delayed(Duration(milliseconds: delay));

    if (this.debug) {
      print('Incrementing > ${this.tape[this.position]} at ${this.position}');
    }
  }

  Future subtract() async {
    try {
      this.tape[this.position] = this.tape[this.position];
    } catch (e) {
      this.tape.add(0);
    }
    await Future.delayed(Duration(milliseconds: delay));
    _tape.sink.add(this.tape);
    --this.tape[this.position];

    if (this.debug) {
      print('Decrementing > ${this.tape[this.position]} at ${this.position}');
    }
  }

  Future shiftLeft() async {
    this.position = --this.position < 0 ? 0 : this.position;

    await Future.delayed(Duration(milliseconds: delay));
    _position.sink.add(this.position);
    if (this.debug) {
      print('Going left to ${this.position}');
    }
  }

  Future shiftRight() async {
    this.position++;

    if (this.tape.length > this.position) {
      await Future.delayed(Duration(milliseconds: delay));
      _position.sink.add(this.position);
    }
    if (this.debug) {
      print('Going right to ${this.position}');
    }
  }

  Future printValue() async {
    this.output.add(String.fromCharCode(this.tape[this.position]));
    this._output.sink.add(this.output);

    if (this.debug) {
      print('Printing ${this.tape[this.position]} at ${this.position}');
    }
  }

  void leftBracket() {
    int openBrackets = 1;
    if (this.tape[this.position] != null && this.tape[this.position] > 0) {
      this.bracketStack.add(this.codePointer);
    } else {
      while (openBrackets > 0 && this.code[++this.codePointer] != null) {
        if (this.code[this.codePointer] == ']') {
          openBrackets--;
        } else if (this.code[this.codePointer] == '[') {
          openBrackets++;
        }
      }
    }
  }

  void rightBracket() {
    this.codePointer = this.bracketStack.removeLast() - 1;
  }

  Future<String> run(String code) async {
    this.code = code
      .replaceAll(RegExp(r"[\dA-Za-z\r\n/# '()\\]"), "")
      .trim()
      .split("");
    List<String> list = ['+', '-', '<', '>', '.', ',', '[', ']'];
    do {
      String c = this.code[this.codePointer];
      if (list.contains(c)) {
        if (this.debug) {
          print('Operation: $c');
        }
        await this.operation(c);
      }
    } while (++this.codePointer < this.code.length);

    String result = this.output.join('');
    _reset();
    return result;
  }

  void _reset() {
    this.code = [];
    this.input = [];
    this.position = 0;
    this.codePointer = 0;
    this.tape = [];
    this.bracketStack = [];
    this.output = [];
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
