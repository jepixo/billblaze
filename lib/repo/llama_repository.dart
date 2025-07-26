
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

  //TODO: for release turn this into llama.dll only since it will be in the root 
  Llama.libraryPath = "D:/Jepixo/CurrYaar/App/billblaze/build/windows/x64/runner/Release/llama.dll";
  final llama = Llama(modelPath, ModelParams(), contextParams, samplerParams, false);
  print(llama.status);

  llama.setPrompt(prompt);
  while (true) {
    final (token, done) = llama.getNext();
    sendPort.send(token);
    if (done) break;
  }

  llama.dispose();
  sendPort.send(null); // signal end
}

void rnLlamaModel(Map args) async {
  final SendPort sendPort = args['sendPort'];
  final String prompt = args['prompt'];
  final String modelPath = args['modelPath'];

  final contextParams = ContextParams()
    ..nPredict = 64
    ..nCtx = 8192
    ..nBatch = 512;

  final samplerParams = SamplerParams()
    ..temp = 0.7
    ..topK = 64
    ..topP = 0.95
    ..penaltyRepeat = 1.1;

  final load = LlamaLoad(
    path: modelPath,
    modelParams: ModelParams(),
    contextParams: contextParams,
    samplingParams: samplerParams,
    format: ChatMLFormat(),
  );

  final llama = LlamaParent(load);

  try {
    await llama.init();

    llama.stream.listen(
      (token) {
        sendPort.send(token);
      },
      onError: (err) {
        sendPort.send("❌ ERROR: $err");
      },
      onDone: () async {
        await llama.dispose();
        sendPort.send(null); // signal end
      },
      cancelOnError: true,
    );

    llama.sendPrompt(prompt);
  } catch (e, st) {
    sendPort.send("❌ INIT ERROR: $e\n$st");
    await llama.dispose();
    sendPort.send(null); // signal end even if failed
  }
}
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';

// class LlamaRepository {
//   /// The single Llama instance / isolate.
//   static late final LlamaParent _llama;

//   /// Initialize the model isolate. Call once at startup.
//   /// [libraryPath] should point at your llama.dll
//   /// [modelPath] your .gguf file.
//   static Future<void> init({required String modelPath,int nGpuLayers = 99,int nCtx = 2048,}) async {
//     // 1) point at the native DLL:
//   print("llama init...");
//     // 2) prepare the load command:
//     final load = LlamaLoad(
//       path: modelPath,
//       modelParams: ModelParams()..nGpuLayers = nGpuLayers,
//       contextParams: ContextParams()
//         ..nPredict = 8192
//         ..nCtx = 8192
//         ..nBatch = 512,
//       samplingParams: SamplerParams()
//         ..temp = 0.7
//         ..topK = 64
//         ..topP = 0.95
//         ..penaltyRepeat = 1.1,
//       format: GeminiFormat(), // or your desired format
//     );

//     // 3) create the isolate:
//     _llama = LlamaParent(load);

//     // 4) init it & wait for ready:
//     await _llama.init();

//     // 5) block until status==ready (or throw):
//     final timeout = Duration(seconds: 30);
//     final sw = Stopwatch()..start();
//     while (_llama.status != LlamaStatus.ready) {
//       if (sw.elapsed > timeout) {
//         throw Exception('Timeout waiting for LlamaStatus.ready, got ${_llama.status}');
//       }
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   /// Send [prompt] to the model.
//   ///
//   /// [onToken] will be called for each streamed token.
//   /// [onDone] will be called once the completion is finished.
//   static Future<void> runPrompt({
//     required String prompt,
//     required void Function(String token) onToken,
//     required void Function() onDone,
//     ChatFormat format = ChatFormat.gemini,
//   }) async {
//     if (_llama.status != LlamaStatus.ready) {
//       throw Exception('Model not ready; call init() first.');
//     }
//     print("runpromptt...");
//     // listen to tokens:
//     final sub = _llama.stream.listen(onToken, onError: (e) {
//       // optionally handle stream error
//       print('Llama token stream error: $e');
//     });

//     // send it:
//     await _llama.sendPrompt(prompt);

//     // listen for completion events (to know when done)
//     var compSub; 
//     compSub = _llama.completions.listen((evt) {
//       if (evt.success) {
//         onDone();
//       } else {
//         print('Llama completion failed: promptId=${evt.promptId}');
//         onDone();
//       }
//       sub.cancel();
//       compSub.cancel();
//     });
//   }

//   /// Clean up the isolate when you're completely done.
//   static Future<void> dispose() async {
//     try {
//       await _llama.dispose();
//     } catch (_) {}
//   }
// }
