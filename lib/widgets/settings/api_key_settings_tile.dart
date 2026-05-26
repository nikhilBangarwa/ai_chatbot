import 'package:flutter/material.dart';

import '../../services/chat/api_key_storage.dart';

/// Groq API key field — persists via [ApiKeyStorage].
class ApiKeySettingsTile extends StatefulWidget {
  const ApiKeySettingsTile({super.key});

  @override
  State<ApiKeySettingsTile> createState() => _ApiKeySettingsTileState();
}

class _ApiKeySettingsTileState extends State<ApiKeySettingsTile> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _loaded = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await ApiKeyStorage.load();
    if (mounted) {
      setState(() {
        _controller.text = key;
        _status = key.isEmpty ? 'Not set' : 'Saved';
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    await ApiKeyStorage.save(_controller.text.trim());
    if (mounted) {
      setState(() => _status = 'Saved');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Groq API Key',
            hintText: 'gsk_...',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ],
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Status: $_status — chat screen par auto load hogi',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _save,
          child: const Text('Save API Key'),
        ),
      ],
    );
  }
}
