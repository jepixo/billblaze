import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

final llamaCtxProvider = StateProvider<ContextParams>((ref) {
  ContextParams contextParams = ContextParams();
  contextParams.nPredict = 64;
  contextParams.nCtx = 2048;
  contextParams.nBatch = 64;
  return contextParams;
});

final llamaSamplerProvider = StateProvider<SamplerParams>((ref) {
  final samplerParams = SamplerParams();
  samplerParams.temp = 0.0;   // pure greedy
  samplerParams.topK = 1;     // only the single most likely token
  samplerParams.topP = 1.0;   // disables nucleus sampling
  samplerParams.penaltyRepeat = 1.0; // no extra penalty needed if greedy

  return samplerParams;
});

final llamaLoadProvider = StateProvider<LlamaLoad>((ref) {
  return LlamaLoad(
    // path: "D:/Jepixo/CurrYaar/App/billblaze/assets/models/phi-2.Q8_0.gguf",
    path: Directory.current.path +"/assets/models/Phi-3-mini-4k-instruct-q4.gguf",
    modelParams: ModelParams(),
    contextParams:ref.read(llamaCtxProvider),
    samplingParams: ref.read(llamaSamplerProvider),
    format: GeminiFormat(),
  );
});

final llamaProvider = StateProvider<LlamaParent>((ref) {
  return LlamaParent(ref.read(llamaLoadProvider));
});

final chatHistoryProvider = StateProvider<ChatHistory>((ref) {
  ChatHistory chatHistory = ChatHistory();
  chatHistory.addMessage(
      role: Role.system,
      content: "You are a concise, analytical assistant. Always focus directly on asnwering the user's prompt, keep responses short and precise, and never include unnecessary elaboration. Only generate the answer and stop.");

  return chatHistory;
});