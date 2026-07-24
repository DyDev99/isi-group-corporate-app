import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/hr_tokens.dart';

/// The input dock. Glass over the scrolling conversation, a send button that
/// morphs out of the mic once there is something to send, and a stop control
/// that replaces it while an answer streams.
class ChatComposer extends StatefulWidget {
  final TextEditingController controller;
  final bool isAnswering;
  final ValueChanged<String> onSubmit;
  final VoidCallback onStop;
  final VoidCallback onOpenKnowledge;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.isAnswering,
    required this.onSubmit,
    required this.onStop,
    required this.onOpenKnowledge,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _submit() {
    final text = widget.controller.text;
    if (text.trim().isEmpty || widget.isAnswering) return;
    widget.onSubmit(text);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: HrColors.canvas.withValues(alpha: 0.86),
            border: const Border(
              top: BorderSide(color: HrColors.hairline),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 6, right: 4),
                          decoration: BoxDecoration(
                            color: HrColors.surface,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: HrColors.hairline),
                            boxShadow: HrShadows.soft(),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: widget.onOpenKnowledge,
                                tooltip: 'Knowledge Center',
                                icon: const Icon(
                                  Icons.folder_open_rounded,
                                  size: 20,
                                  color: HrColors.inkMuted,
                                ),
                              ),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 110),
                                  child: TextField(
                                    controller: widget.controller,
                                    minLines: 1,
                                    maxLines: 5,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _submit(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: HrColors.ink,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Ask about leave, pay, IT…',
                                      hintStyle:
                                          TextStyle(color: HrColors.inkFaint),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _primaryButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _disclaimer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton() {
    if (widget.isAnswering) {
      return GestureDetector(
        onTap: widget.onStop,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: HrColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: HrColors.hairline),
            boxShadow: HrShadows.soft(),
          ),
          child: const Icon(Icons.stop_rounded,
              color: HrColors.danger, size: 22),
        ),
      );
    }

    return GestureDetector(
      onTap: _hasText ? _submit : null,
      child: AnimatedContainer(
        duration: HrMotion.base,
        curve: HrMotion.enter,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: _hasText ? HrColors.brandGradient : null,
          color: _hasText ? null : HrColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: _hasText ? Colors.transparent : HrColors.hairline,
          ),
          boxShadow: _hasText ? HrShadows.brandGlow() : HrShadows.soft(),
        ),
        child: AnimatedSwitcher(
          duration: HrMotion.fast,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            _hasText ? Icons.arrow_upward_rounded : Icons.mic_none_rounded,
            key: ValueKey(_hasText),
            color: _hasText ? Colors.white : HrColors.inkMuted,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _disclaimer() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 11, color: HrColors.inkFaint),
          const SizedBox(width: 5),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Answers cite policy documents. Check anything critical in the ',
                  ),
                  TextSpan(
                    text: 'Knowledge Center',
                    style: const TextStyle(
                      color: HrColors.inkMuted,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: HrColors.inkFaint),
            ),
          ),
        ],
      );
}
