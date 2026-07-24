import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../bloc/hr_chat_bloc.dart';
import '../theme/hr_tokens.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/knowledge_center_sheet.dart';
import '../widgets/suggested_questions.dart';
import '../widgets/typing_indicator.dart';

/// Gesture map for this screen:
///   • swipe left on your own message  → delete it
///   • swipe right on an answer        → ask again
///   • swipe the scope bar             → change what the assistant searches
///   • swipe the source cards          → page through the evidence
///   • pinch / double-tap in a source  → zoom the cited page (0.6× – 5×)
///   • long-press any bubble           → copy, re-ask, delete
class HrAiAssistantScreen extends StatefulWidget {
  const HrAiAssistantScreen({super.key});

  @override
  State<HrAiAssistantScreen> createState() => _HrAiAssistantScreenState();
}

class _HrAiAssistantScreenState extends State<HrAiAssistantScreen> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showJumpButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final distanceFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    final shouldShow = distanceFromBottom > 260;
    if (shouldShow != _showJumpButton) {
      setState(() => _showJumpButton = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: HrMotion.base,
          curve: HrMotion.enter,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _ask(BuildContext context, String question) {
    FocusScope.of(context).unfocus();
    context.read<HrChatBloc>().add(HrChatQuestionSubmitted(question));
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HrColors.ink,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Answer copied'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HrChatBloc, HrChatState>(
      listenWhen: (previous, current) {
        if (previous.messages.length != current.messages.length) return true;
        final before =
            previous.messages.isEmpty ? null : previous.messages.last;
        final after = current.messages.isEmpty ? null : current.messages.last;
        return before?.text.length != after?.text.length;
      },
      listener: (context, state) {
        if (!_showJumpButton) _scrollToBottom(animated: false);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: HrColors.canvas,
          appBar: _appBar(context, state),
          body: Stack(
            children: [
              // 1. Subtle Grid Pattern Background
              const Positioned.fill(
                child: CleanGridBackground(),
              ),

              // 2. Foreground Layout
              Column(
                children: [
                  const SizedBox(height: 10),
                  CategoryFilterBar(
                    selected: state.category,
                    onSelected: (category) => context
                        .read<HrChatBloc>()
                        .add(HrChatCategoryChanged(category)),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        _conversation(context, state),
                        if (_showJumpButton)
                          Positioned(
                            right: 16,
                            bottom: 12,
                            child: _jumpToLatestButton(),
                          ),
                      ],
                    ),
                  ),
                  if (state.failureMessage != null) _failureBanner(state),
                  ChatComposer(
                    controller: _composerController,
                    isAnswering: state.isAnswering,
                    onSubmit: (text) => _ask(context, text),
                    onStop: () => context
                        .read<HrChatBloc>()
                        .add(const HrChatGenerationStopped()),
                    onOpenKnowledge: () =>
                        showKnowledgeCenter(context, context.read<HrChatBloc>()),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Conversation ──────────────────────────────────────────────────────────

  Widget _conversation(BuildContext context, HrChatState state) {
    if (state.status == HrChatStatus.loading || state.messages.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    final showSuggestions =
        state.isGreetingOnly && state.suggestions.isNotEmpty;

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      itemCount: state.messages.length + (showSuggestions ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SuggestedQuestions(
              key: ValueKey(state.category),
              questions: state.suggestions,
              onSelected: (question) => _ask(context, question),
            ),
          );
        }

        final message = state.messages[index];

        // An answer that has been requested but not yet started writing.
        if (message.isStreaming && message.text.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    gradient: HrColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 16),
                ),
                const TypingIndicator(),
              ],
            ),
          );
        }

        return _AppearOnce(
          key: ValueKey(message.id),
          fromRight: message.isUser,
          child: _swipeable(
            context,
            message,
            ChatBubble(
              message: message,
              textScale: state.textScale,
              onCopy: () => _copy(context, message.text),
              onRegenerate: () => context
                  .read<HrChatBloc>()
                  .add(HrChatAnswerRegenerated(message.id)),
              onReact: (reaction) => context
                  .read<HrChatBloc>()
                  .add(HrChatMessageReacted(message.id, reaction)),
              onFollowUp: (question) => _ask(context, question),
            ),
          ),
        );
      },
    );
  }

  /// Swipe left to delete your own message, swipe right on an answer to have
  /// it written again. Long-press opens the same actions as a menu.
  Widget _swipeable(
    BuildContext context,
    ChatMessage message,
    Widget child,
  ) {
    final bloc = context.read<HrChatBloc>();

    return Dismissible(
      key: ValueKey('swipe_${message.id}'),
      direction: message.isUser
          ? DismissDirection.endToStart
          : DismissDirection.startToEnd,
      resizeDuration: HrMotion.base,
      background: _swipeBackground(
        alignment: Alignment.centerLeft,
        icon: Icons.refresh_rounded,
        label: 'Ask again',
        color: HrColors.brand,
      ),
      secondaryBackground: _swipeBackground(
        alignment: Alignment.centerRight,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        color: HrColors.danger,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          bloc.add(HrChatAnswerRegenerated(message.id));
          return false; // snap back — the bubble is replaced, not removed
        }
        return true;
      },
      onDismissed: (_) => bloc.add(HrChatMessageDismissed(message.id)),
      child: GestureDetector(
        onLongPress: () => _showMessageActions(context, message),
        child: child,
      ),
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: alignment,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(HrRadius.bubble),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );

  Future<void> _showMessageActions(
    BuildContext context,
    ChatMessage message,
  ) async {
    final bloc = context.read<HrChatBloc>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: HrColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HrRadius.sheet)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: HrColors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: HrColors.inkBody),
              title: const Text('Copy text'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copy(context, message.text);
              },
            ),
            if (!message.isUser)
              ListTile(
                leading:
                    const Icon(Icons.refresh_rounded, color: HrColors.inkBody),
                title: const Text('Answer again'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  bloc.add(HrChatAnswerRegenerated(message.id));
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: HrColors.danger),
              title: const Text('Delete message',
                  style: TextStyle(color: HrColors.danger)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                bloc.add(HrChatMessageDismissed(message.id));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Chrome ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _appBar(BuildContext context, HrChatState state) {
    final bloc = context.read<HrChatBloc>();

    return AppBar(
      backgroundColor: HrColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 18,
      title: Row(
        children: [
          _PulseAvatar(active: state.isAnswering),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Text(
                      'HR Assistant',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: HrColors.ink,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified_rounded,
                        color: HrColors.brand, size: 15),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: state.isAnswering
                            ? HrColors.warn
                            : HrColors.online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.isAnswering
                          ? 'Composing an answer'
                          : 'Online · ${state.category.label}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: state.isAnswering
                            ? HrColors.warn
                            : HrColors.online,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _TextScaleButton(
          scale: state.textScale,
          onChanged: (value) => bloc.add(HrChatTextScaleChanged(value)),
        ),
        IconButton(
          tooltip: 'Knowledge Center',
          onPressed: () => showKnowledgeCenter(context, bloc),
          icon: const Icon(Icons.folder_open_rounded,
              color: HrColors.inkMuted, size: 21),
        ),
        IconButton(
          tooltip: 'Clear conversation',
          onPressed: () => bloc.add(const HrChatCleared()),
          icon: const Icon(Icons.restart_alt_rounded,
              color: HrColors.inkMuted, size: 21),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: HrColors.surfaceMuted, height: 1),
      ),
    );
  }

  Widget _jumpToLatestButton() => GestureDetector(
        onTap: _scrollToBottom,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: HrColors.surface,
            borderRadius: BorderRadius.circular(HrRadius.chip),
            border: Border.all(color: HrColors.hairline),
            boxShadow: HrShadows.lifted(),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_downward_rounded,
                  size: 15, color: HrColors.brand),
              SizedBox(width: 6),
              Text(
                'Latest',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HrColors.brand,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _failureBanner(HrChatState state) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: HrColors.danger.withValues(alpha: 0.08),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 16, color: HrColors.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.failureMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: HrColors.danger,
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Small local widgets ─────────────────────────────────────────────────────

/// Plays a fade + slide once when a message first appears in the list.
class _AppearOnce extends StatefulWidget {
  final Widget child;
  final bool fromRight;

  const _AppearOnce({super.key, required this.child, this.fromRight = false});

  @override
  State<_AppearOnce> createState() => _AppearOnceState();
}

class _AppearOnceState extends State<_AppearOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: HrMotion.slow,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: HrMotion.enter);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(widget.fromRight ? 0.12 : -0.06, 0.14),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Avatar with a ring that only pulses while an answer is being composed.
class _PulseAvatar extends StatefulWidget {
  final bool active;

  const _PulseAvatar({required this.active});

  @override
  State<_PulseAvatar> createState() => _PulseAvatarState();
}

class _PulseAvatarState extends State<_PulseAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _PulseAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Container(
              width: 30 + (_controller.value * 12),
              height: 30 + (_controller.value * 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HrColors.brand
                    .withValues(alpha: 0.22 * (1 - _controller.value)),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: HrColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 19),
          ),
        ],
      ),
    );
  }
}

/// A− / A+ control: scales every message body between 90% and 130%.
class _TextScaleButton extends StatelessWidget {
  final double scale;
  final ValueChanged<double> onChanged;

  const _TextScaleButton({required this.scale, required this.onChanged});

  static const Map<String, double> _options = {
    'Small': 0.9,
    'Default': 1.0,
    'Large': 1.15,
    'Largest': 1.3,
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Text size',
      offset: const Offset(0, 46),
      color: HrColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: const Icon(Icons.format_size_rounded,
          color: HrColors.inkMuted, size: 21),
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final entry in _options.entries)
          PopupMenuItem<double>(
            value: entry.value,
            child: Row(
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: scale == entry.value
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: scale == entry.value
                        ? HrColors.brand
                        : HrColors.inkBody,
                  ),
                ),
                const Spacer(),
                if (scale == entry.value)
                  const Icon(Icons.check_rounded,
                      size: 16, color: HrColors.brand),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Background Grid Pattern ──────────────────────────────────────────────────

class CleanGridBackground extends StatelessWidget {
  const CleanGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPatternPainter(),
      child: Container(),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSize = 24.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}