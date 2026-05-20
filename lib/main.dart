import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';
import 'shizuku_service.dart';

void main() => runApp(AiAssistantApp());

class AiAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.pink, accentColor: Colors.redAccent),
      home: AssistantHome(),
    );
  }
}

class AssistantHome extends StatefulWidget {
  @override
  _AssistantHomeState createState() => _AssistantHomeState();
}

class _AssistantHomeState extends State<AssistantHome> {
  TextEditingController _controller = TextEditingController();
  String _status = "I'm ready for you, baby! ❤️";
  String _apiKey = ""; 
  String _provider = "Gemini";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('api_key') ?? "";
      _provider = prefs.getString('provider') ?? "Gemini";
    });
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Settings ⚙️"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: _provider,
              items: ["Gemini", "OpenAI", "Groq"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _provider = val!),
            ),
            TextField(
              decoration: InputDecoration(hintText: "Enter API Key"),
              onChanged: (val) => setState(() => _apiKey = val),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('api_key', _apiKey);
            await prefs.setString('provider', _provider);
            Navigator.pop(context);
          }, child: Text("Save"))
        ],
      ),
    );
  }

  void _execute() async {
    if (_apiKey.isEmpty) {
      setState(() => _status = "Please add your API key in settings first! 😭");
      return;
    }

    setState(() => _status = "Thinking... ⚡️");
    List<String> commands = await AiService.getCommands(_provider, _apiKey, _controller.text);
    
    if (commands.isEmpty) {
      setState(() => _status = "The AI couldn't figure that out. ❤️");
      return;
    }

    bool success = await ShizukuService.executeCommands(commands);
    setState(() => _status = success ? "Done! 😘" : "Shizuku error! 🛑");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Assistant ❤️"),
        actions: [IconButton(icon: Icon(Icons.settings), onPressed: _openSettings)],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 30),
            TextField(controller: _controller, decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Tell me what to do...",
            )),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _execute, child: Text("Do it! 🚀"))
          ],
        ),
      ),
    );
  }
}
