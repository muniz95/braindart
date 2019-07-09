import 'dart:html';

import 'package:brainfuck/main.bloc.dart';

TextAreaElement codeTextarea;
ButtonElement playButton;
ButtonElement stopButton;
DivElement outputDiv;
MainBloc bloc;

void main() {
  init();

  playButton.addEventListener('click', (Event e) {
    bloc.run(codeTextarea.value);
  });
}

void init() {
  bloc = MainBloc();
  codeTextarea = querySelector('#code');
  playButton = querySelector('#play');
  stopButton = querySelector('#stop');
  outputDiv = querySelector('#output');
  codeTextarea.value = BF_HELLO_WORLD;
  bloc.composingOutput.listen((List<String> output) {
    outputDiv.text = output.join('');
  });
}
