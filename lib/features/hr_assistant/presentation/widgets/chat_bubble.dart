import 'package:flutter/material.dart';

import '../../domain/entities/chat_message.dart';
import '../theme/hr_tokens.dart';
import 'leave_balance_card.dart';
import 'source_carousel.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final double textScale;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final ValueChanged<MessageReaction> onReact;
  final ValueChanged<String> onFollowUp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.textScale,
    required this.onCopy,
    required this.onRegenerate,
    required this.onReact,
    required this.onFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    return message.isUser ? _userBubble() : _assistantBubble(context);
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Widget _userBubble() => Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: HrColors.userBubble,
            borderRadius: BorderRadius.circular(HrRadius.bubble)
                .copyWith(bottomRight: const Radius.circular(6)),
            boxShadow: HrShadows.brandGlow(),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 14 * textScale,
              height: 1.45,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  // ── Assistant ─────────────────────────────────────────────────────────────

  Widget _assistantBubble(BuildContext context) {
    final failed = message.status == MessageStatus.failed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              gradient: failed ? null : HrColors.brandGradient,
              color: failed ? HrColors.danger : null,
              shape: BoxShape.circle,
              boxShadow: HrShadows.soft(),
            ),
            child: Icon(
              failed ? Icons.priority_high_rounded : Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: HrColors.surface,
                    borderRadius: BorderRadius.circular(HrRadius.bubble)
                        .copyWith(topLeft: const Radius.circular(6)),
                    border: Border.all(
                      color: failed ? HrColors.danger.withValues(alpha: 0.35)
                          : HrColors.hairline,
                    ),
                    boxShadow: HrShadows.soft(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bodyText(),
                      if (message.leaveBalance != null)
                        LeaveBalanceCard(balance: message.leaveBalance!),
                      if (message.confidence != null && !message.isStreaming)
                        _confidenceMeter(),
                    ],
                  ),
                ),
                if (message.sources.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SourceCarousel(sources: message.sources),
                ],
                if (!message.isStreaming && message.confidence != null)
                  _actionsRow(context),
                if (message.followUps.isNotEmpty && !message.isStreaming)
                  _followUps(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyText() {
    if (message.text.isEmpty) {
      return const _Caret();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 14 * textScale,
              height: 1.55,
              color: HrColors.inkBody,
            ),
          ),
        ),
        if (message.isStreaming) const _Caret(),
      ],
    );
  }

  Widget _confidenceMeter() {
    final confidence = message.confidence ?? 0;
    final color = confidence >= 0.85
        ? HrColors.online
        : confidence >= 0.6
            ? HrColors.warn
            : HrColors.danger;
    final label = confidence >= 0.85
        ? 'Grounded in policy'
        : confidence >= 0.6
            ? 'Partly grounded'
            : 'Not found in policy';

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 4,
            decoration: BoxDecoration(
              color: HrColors.surfaceMuted,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: confidence.clamp(0.08, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsRow(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10, left: 2),
        child: Row(
          children: [
            _action(
              icon: Icons.copy_rounded,
              tooltip: 'Copy answer',
              onTap: onCopy,
            ),
            _action(
              icon: Icons.refresh_rounded,
              tooltip: 'Answer again',
              onTap: onRegenerate,
            ),
            const SizedBox(width: 2),
            Container(width: 1, height: 16, color: HrColors.hairline),
            const SizedBox(width: 2),
            _action(
              icon: message.reaction == MessageReaction.helpful
                  ? Icons.thumb_up_rounded
                  : Icons.thumb_up_outlined,
              tooltip: 'Helpful',
              active: message.reaction == MessageReaction.helpful,
              onTap: () => onReact(MessageReaction.helpful),
            ),
            _action(
              icon: message.reaction == MessageReaction.notHelpful
                  ? Icons.thumb_down_rounded
                  : Icons.thumb_down_outlined,
              tooltip: 'Not helpful',
              active: message.reaction == MessageReaction.notHelpful,
              activeColor: HrColors.danger,
              onTap: () => onReact(MessageReaction.notHelpful),
            ),
          ],
        ),
      );

  Widget _action({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool active = false,
    Color activeColor = HrColors.brand,
  }) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              icon,
              size: 16,
              color: active ? activeColor : HrColors.inkFaint,
            ),
          ),
        ),
      );

  Widget _followUps() => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: message.followUps.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = message.followUps[index];
              return GestureDetector(
                onTap: () => onFollowUp(label),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: HrColors.brandWash,
                    borderRadius: BorderRadius.circular(HrRadius.chip),
                    border: Border.all(
                        color: HrColors.brand.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HrColors.brand,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

/// Blinking block that marks where the answer is still being written.
class _Caret extends StatefulWidget {
  const _Caret();

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _controller,
        child: Container(
          width: 8,
          height: 15,
          margin: const EdgeInsets.only(left: 3, bottom: 2),
          decoration: BoxDecoration(
            color: HrColors.brand,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}
