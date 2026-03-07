import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';

class ShowNameScreen extends StatefulWidget {
  final RealityTvGame game;

  const ShowNameScreen({super.key, required this.game});

  @override
  State<ShowNameScreen> createState() => _ShowNameScreenState();
}

class _ShowNameScreenState extends State<ShowNameScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    widget.game.submitShowName(name);
  }

  static const _pink = Color(0xFFFF1493);
  static const _fontFamily = 'VT323';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      child: Center(
        child: Container(
          width: 900,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
          decoration: BoxDecoration(
            color: const Color(0xEE111111),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _pink, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Congratulations! You're the hottest new\n"
                'Reality TV producer in Hollywood!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "What's the name of your brand new show?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 36,
                  color: _pink,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 30,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 36,
                  color: Colors.white,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                ],
                decoration: InputDecoration(
                  counterStyle: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  hintText: 'Enter show name...',
                  hintStyle: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 36,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  errorText: _showError ? 'Your show needs a name!' : null,
                  errorStyle: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 22,
                    color: Colors.redAccent,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: _pink, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
