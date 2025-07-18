import 'dart:io';

import 'package:billblaze/home.dart';
import 'package:billblaze/providers/llama_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LlamaRepository {
  
  static init(WidgetRef ref) async {
    print("llama initializing...");
    try {
    await ref.read(llamaProvider).init();
    var llamaParent = ref.read(llamaProvider);
    // Add a timeout to prevent infinite waiting
    int attempts = 0;
    const maxAttempts = 200;

    print("Waiting for model to be ready...");
    while (llamaParent.status != LlamaStatus.ready && attempts < maxAttempts) {
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;

      if (attempts % 10 == 0) {
        print("Still waiting... Status: ${llamaParent.status}");
      }

      if (llamaParent.status == LlamaStatus.error) {
        print("Error loading model. Exiting.");
        // exit(1);
      }
    }

    if (attempts >= maxAttempts && llamaParent.status != LlamaStatus.ready) {
      print(
          "Timeout waiting for model to be ready. Current status: ${llamaParent.status}");
      print(
          "Continuing anyway as the model might be ready despite status not being updated...");
    }

    print(
        "Model loaded successfully in isolate! Status: ${llamaParent.status}");
    ref.read(llamaProvider.notifier).state = llamaParent;    
    llamaParent.sendPrompt(ref.read(chatHistoryProvider).exportFormat(ChatFormat.gemini));
     ref.read(llamaProvider).stream.listen((token) {
    ref.read(aiTokenProvider.notifier).state = ref.read(aiTokenProvider.notifier).state+token;

      // currentResponse.write(token);
    }, onError: (e) {
      print("\nSTREAM ERROR: $e");
    });
  } catch (e) {
    print("Error initializing model: $e");
    // exit(1);
  }



  }

  static llamaRun(WidgetRef ref, String prompt) async {
    // await ref.read(llamaProvider).dispose();
    await init(ref);
    print("sending prompt...");
    ref.read(aiTokenProvider.notifier).state ='';
    var chatHistory = ref.read(chatHistoryProvider);
    chatHistory.addMessage(role: Role.user, content: prompt+'\n<|assisstant|>');
    ref.read(chatHistoryProvider.notifier).state = chatHistory;
    await ref.read(llamaProvider).sendPrompt(ref.read(chatHistoryProvider).exportFormat(ChatFormat.gemini));
    StringBuffer currentResponse = StringBuffer();
    ref.read(llamaProvider).stream.listen((token) {
    ref.read(aiTokenProvider.notifier).state = ref.read(aiTokenProvider.notifier).state+token;

      currentResponse.write(token);
    }, onError: (e) {
      print("\nSTREAM ERROR: $e");
    });
    // var chatHistory = ref.read(chatHistoryProvider);
    ref.read(llamaProvider).completions.listen((event) async {
    if (event.success) {
      final notifier = ref.read(chatHistoryProvider.notifier);
      final history = notifier.state;
      final messages = history.messages;
      if (messages.isNotEmpty &&
          messages.last.role == Role.assistant) {
        messages.last =
            Message(role: Role.assistant, content: currentResponse.toString());
        notifier.state = history;

        final full = history.messages; // returns List<Map<String, String>>
        if (full.length > 5) {
          final recent = full.sublist(full.length - 3); 
          final older = full.sublist(0, full.length - 3);
          // final summaryPrompt = await _buildSummary(ref, older.sublist(1)); // your summarization logic
          
          history.clear();
          // history.addMessage(role: older[0].role, content: older[0].content);
          // history.addMessage(role: Role.system, content: summaryPrompt);
          for (var i = 0; i < 3; i++) {
            history.addMessage(role: recent[i].role, content: recent[i].content);
          }
          notifier.state = history;
        }


      }
      currentResponse.clear();
    } else {
      print("Completion failed for prompt: ${event.promptId}");
    }
    await ref.read(llamaProvider.notifier).state.dispose();
    await ref.read(llamaProvider).dispose();
    // await init(ref);
  });

  }
  
  static Future<String> _buildSummary(
  WidgetRef ref,
  List<Message> older,
  ) async {
    final history = ChatHistory();
    // Prepare summarization instructions
    for (var i = 0; i < 2; i++) {
      history.addMessage(role: older[i].role, content: older[i].content);
    }
    history.addMessage(role: Role.user, content: "Summarize the following conversation in ≤7 concise lines:");
    
    // Send prompt and collect tokens
    await ref.read(llamaProvider.notifier).state.sendPrompt(history.exportFormat(ChatFormat.gemini));
    
    final sb = StringBuffer();
    await for (final token in ref.read(llamaProvider).stream) {
      sb.write(token);
    }
    return sb.toString().trim();
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
