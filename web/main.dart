import 'dart:html';

import 'package:brainfuck/main.bloc.dart';

TextAreaElement codeTextarea;
ButtonElement playButton;
ButtonElement stopButton;
MainBloc bloc;

void main() {
  init();

  playButton.addEventListener('click', (Event e) {
    window.alert(bloc.runCode(codeTextarea.value));
  });
  querySelector('#output').text = 'Your Dart app is running.';
}

void init() {
  bloc = MainBloc();
  codeTextarea = querySelector('#code');
  playButton = querySelector('#play');
  stopButton = querySelector('#stop');
  codeTextarea.value = BF_HELLO_WORLD;
}
