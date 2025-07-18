import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:billblaze/home.dart';
import 'package:billblaze/providers/llama_provider.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LlamaRespository {
  
  static init(WidgetRef ref) async {

    try {
    await ref.read(llamaProvider.notifier).state.init();
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
        exit(1);
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
  } catch (e) {
    print("Error initializing model: $e");
    exit(1);
  }



  }

  static llamaRun(WidgetRef ref, String prompt) async {

    await ref.read(llamaProvider.notifier).state.sendPrompt(ref.read(chatHistoryProvider).exportFormat(ChatFormat.gemini));
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
          final summaryPrompt = await _buildSummary(ref, older.sublist(1)); // your summarization logic
          final newHistory = [
            {'role': 'system', 'content': summaryPrompt},
            ...recent
          ];
          history.clear();
          history.addMessage(role: older[0].role, content: older[0].content);
          history.addMessage(role: Role.system, content: summaryPrompt);
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



