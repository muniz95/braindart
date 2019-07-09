class Brainfuck {
  List<String> code;
  int pointer;
  int codePointer;
  List<int> dataset;
  List<int> bracketStack;
  List<String> input;
  List<String> output;

  Brainfuck(String code) {
    this.code = code.trim().replaceAll(' ', "").replaceAll(RegExp(r'/(\r\n|\n|\r)/gm'), "").split("");
    this.input = [];
    this.pointer = 0;
    this.codePointer = 0;
    this.dataset = [];
    this.bracketStack = [];
    this.output = [];
  }

  operation(str) {

    switch (str) {
      case '+': {
        try {
          this.dataset[this.pointer] = this.dataset[this.pointer];
        } catch (e) {
          this.dataset.add(0);
        }
        ++this.dataset[this.pointer];
        break;
      }

      case '-': {
        try {
          this.dataset[this.pointer] = this.dataset[this.pointer];
        } catch (e) {
          this.dataset.add(0);
        }
        --this.dataset[this.pointer];
        break;
      }

      case '<': {
        this.pointer = --this.pointer < 0 ? 0 : this.pointer;
        break;
      }

      case '>': {
        this.pointer++;
        break;
      }

      case '.': {
        this.output.add(String.fromCharCode(this.dataset[this.pointer]));
        break;
      }

      case ',': {
        String c = this.input.removeAt(0);
        this.dataset[this.pointer] = c.codeUnitAt(0);
        break;
      }

      case '[': {
        this.leftBracket();
        break;
      }

      case ']': {
        this.rightBracket();
        break;
      }
    }

  }

  void leftBracket() {
    int openBrackets = 1;
    if (this.dataset[this.pointer] != null) {
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

  List<String> run() {
    List<String> list = ['+', '-', '<', '>', '.', ',', '[', ']'];
    do {
      String c = this.code[this.codePointer];
      if (list.contains(c)) {
        this.operation(c);
      }
    } while (++this.codePointer < this.code.length);
    return this.output;
  }

  toString() {
    return this.run().join('');
  }

}