import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  static Future<List<String>> getCommands(String provider, String apiKey, String userText) async {
    String url = "";
    Map<String, dynamic> body = {};
    String systemPrompt = "You are an Android shell expert. Convert the user request into a JSON list of shell commands for Shizuku. Return ONLY the JSON array. No explanation.";

    if (provider == "Gemini") {
      url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";
      body = {"contents": [{"parts": [{"text": "$systemPrompt\n\nUser: $userText"}]}]};
    } else if (provider == "OpenAI") {
      url = "https://api.openai.com/v1/chat/completions";
      body = {"model": "gpt-3.5-turbo", "messages": [{"role": "system", "content": systemPrompt}, {"role": "user", "content": userText}]};
    }

    try {
      var response = await http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
      var data = jsonDecode(response.body);
      String aiText = (provider == "Gemini") ? data['candidates'][0]['content']['parts'][0]['text'] : data['choices'][0]['message']['content'];
      aiText = aiText.replaceAll("```json", "").replaceAll("```", "").trim();
      return List<String>.from(jsonDecode(aiText));
    } catch (e) {
      return [];
    }
  }
}
