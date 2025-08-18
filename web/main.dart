import 'dart:html';

import 'package:brainfuck/main.bloc.dart';
import 'package:logging/logging.dart';

const double speedRatio = 100000;

late TextAreaElement codeTextarea;
late ButtonElement playButton;
late ButtonElement pauseButton;
late ButtonElement resumeButton;
late ButtonElement stopButton;
late InputElement speedSlider;
late DivElement outputDiv;
late MainBloc bloc;

void main() {
  // Set up logging to also output to the browser console
  Logger.root.onRecord.listen((LogRecord rec) {
    window.console.log('${rec.level.name}: ${rec.message}');
  });
  
  init();

  playButton.addEventListener('click', (Event e) {
    outputDiv.text = '';
    final code = codeTextarea.value;
    if (code != null) {
      // Enable pause button when starting execution
      pauseButton.disabled = false;
      resumeButton.disabled = true;
      playButton.disabled = true;
      bloc.run(code);
    }
  });
  
  pauseButton.addEventListener('click', (Event e) {
    pauseButton.disabled = true;
    resumeButton.disabled = false;
    bloc.pause();
  });
  
  resumeButton.addEventListener('click', (Event e) {
    pauseButton.disabled = false;
    resumeButton.disabled = true;
    bloc.resume();
  });
  
  speedSlider.addEventListener('change', (Event event) {
    final target = event.target;
    if (target is InputElement && target.value != null) {
      var speed = speedRatio / int.parse(target.value as String);
      bloc.delay.sink.add(speed);
    }
  });
  
  stopButton.addEventListener('click', (event) {
    // Reset all button states when stopping
    playButton.disabled = false;
    pauseButton.disabled = false;
    resumeButton.disabled = true;
    bloc.stop();
  });
}

void init() {
  bloc = MainBloc();
  
  codeTextarea = querySelector('#code') as TextAreaElement;
  playButton = querySelector('#play') as ButtonElement;
  pauseButton = querySelector('#pause') as ButtonElement;
  resumeButton = querySelector('#resume') as ButtonElement;
  stopButton = querySelector('#stop') as ButtonElement;
  speedSlider = querySelector('#speed') as InputElement;
  outputDiv = querySelector('#output') as DivElement;
  
  codeTextarea.value = BF_HELLO_WORLD;
  
  // Initially disable resume button
  resumeButton.disabled = true;
  
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
  
  // Listen for completion of execution to reset button states
  bloc.isStopped.listen((bool isStopped) {
    if (isStopped) {
      playButton.disabled = false;
      pauseButton.disabled = false;
      resumeButton.disabled = true;
    }
  });
}

void _buildTape(List<int> tape) {
  // Get the tape container from our new HTML structure
  final tapeContainer = querySelector('.tape-visualizer');
  if (tapeContainer == null) return;
  
  // Create the tape element
  var tapeDiv = DivElement()..id = 'tape';
  
  // Create cells
  tape.asMap().forEach((int index, int value) {
    tapeDiv.append(_buildCell(value, index == bloc.position));
  });
  
  // Clear any existing tape and add the new one
  tapeContainer.children.clear();
  tapeContainer.append(tapeDiv);
}

DivElement _buildCell(int value, bool isActive) {
  var classes = <String>['cell'];
  if (isActive) {
    classes.add('active');
  }
  
  // Add cell index as data attribute for better visualization
  var cell = DivElement()
    ..innerText = value.toString()
    ..classes = classes
    ..attributes['data-index'] = bloc.position.toString();
    
  return cell;
}
