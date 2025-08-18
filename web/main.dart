import 'dart:html';

import 'package:brainfuck/main.bloc.dart';

const double speedRatio = 100000;

late TextAreaElement codeTextarea;
late ButtonElement playButton;
late ButtonElement stopButton;
late InputElement speedSlider;
late DivElement outputDiv;
late MainBloc bloc;

void main() {
  init();

  playButton.addEventListener('click', (Event e) {
    outputDiv.text = '';
    final code = codeTextarea.value;
    if (code != null) {
      bloc.run(code);
    }
  });
  
  speedSlider.addEventListener('change', (Event event) {
    final target = event.target;
    if (target is InputElement && target.value != null) {
      var speed = speedRatio / int.parse(target.value as String);
      bloc.delay.sink.add(speed);
    }
  });
  
  stopButton.addEventListener('click', (event) {
    bloc.stop();
  });
}

void init() {
  bloc = MainBloc();
  
  codeTextarea = querySelector('#code') as TextAreaElement;
  playButton = querySelector('#play') as ButtonElement;
  stopButton = querySelector('#stop') as ButtonElement;
  speedSlider = querySelector('#speed') as InputElement;
  outputDiv = querySelector('#output') as DivElement;
  
  codeTextarea.value = BF_HELLO_WORLD;
  
  bloc.composingOutput.listen((List<String> output) {
    outputDiv.text = output.join('');
  });
  
  bloc.tapeStream.listen((List<int> tape) {
    final tapeElement = document.getElementById('tape');
    if (tapeElement != null) {
      tapeElement.remove();
    }
    _buildTape(tape);
  });
  
  bloc.positionStream.listen((int position) {
    final tapeElement = document.getElementById('tape');
    if (tapeElement != null) {
      tapeElement.remove();
    }
    _buildTape(bloc.tape);
  });
}

void _buildTape(List<int> tape) {
  var tapeDiv = DivElement()..id = 'tape';
  tape.asMap().forEach((int index, int value) {
    tapeDiv.append(_buildCell(value, index == bloc.position));
  });
  document.body?.append(tapeDiv);
}

DivElement _buildCell(int value, bool isActive) {
  var classes = <String>['cell'];
  if (isActive) {
    classes.add('active');
  }
  var cell = DivElement()
    ..innerText = value.toString()
    ..classes = classes;
  return cell;
}
