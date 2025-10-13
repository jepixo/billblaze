
import 'dart:isolate';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void runLlamaModel(Map args) async {
  final sendPort = args['sendPort'] as SendPort;
  final prompt = args['prompt'] as String;
  final modelPath = args['modelPath'] as String;
  final contextParams = ContextParams()
      ..nPredict = 128
      ..nCtx = 8192
      ..nBatch = 2048;
  print(contextParams);
  final samplerParams = SamplerParams()
    ..temp = 0.7
    ..topK = 64
    ..topP = 0.95
    ..penaltyRepeat = 1.1;
  try { 
    
    
    //TODO: for release turn this into llama.dll only since it will be in the root 
    // Llama.libraryPath = "D:/Jepixo/CurrYaar/App/billblaze/build/windows/x64/runner/Release/llama.dll";
    print(Llama.libraryPath);
    Llama.libraryPath = 'llama.dll';
    print(Llama.libraryPath);
    final llama = Llama(modelPath, ModelParams(), contextParams, samplerParams, false);
    print(llama.status);
    
    llama.setPrompt(prompt);
    while (true) {
      final (token, done) = llama.getNext();
      sendPort.send(token);
      if (done) break;
    }
    
    llama.dispose();
    sendPort.send(null); 
  } on Exception catch (e, st) {
    sendPort.send("ERROR:\n$e\n$st\n${Llama.libraryPath.toString()}\n${contextParams}");

    sendPort.send(null); 
  }
// signal end
}