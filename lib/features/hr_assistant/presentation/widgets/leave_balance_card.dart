import 'package:flutter/material.dart';

import '../../domain/entities/leave_balance.dart';
import '../theme/hr_tokens.dart';

/// Rich payload attached to a leave answer: the numbers the sentence is
/// talking about, animated in so the bars draw rather than appear.
class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalance balance;

  const LeaveBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFF), Color(0xFFEFF4FF)],
        ),
        borderRadius: BorderRadius.circular(HrRadius.card),
        border: Border.all(color: HrColors.brandWash),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_rounded,
                  size: 16, color: HrColors.brand),
              const SizedBox(width: 8),
              const Text(
                'Your balance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: HrColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'as of ${balance.asOf.day}/${balance.asOf.month}',
                style: const TextStyle(
                    fontSize: 10.5, color: HrColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final bucket in balance.buckets) ...[
            _BucketRow(bucket: bucket),
            const SizedBox(height: 12),
          ],
          Container(height: 1, color: HrColors.brandWash),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: HrColors.inkMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pending days are already reserved against an unapproved request.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: HrColors.inkMuted.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BucketRow extends StatelessWidget {
  final LeaveBucket bucket;

  const _BucketRow({required this.bucket});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              bucket.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: HrColors.inkBody,
              ),
            ),
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: bucket.remaining),
              duration: HrMotion.slow,
              curve: HrMotion.enter,
              builder: (context, value, _) => RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: HrColors.brandDeep,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${bucket.entitled.toStringAsFixed(0)} days',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: HrColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: bucket.consumedRatio),
            duration: HrMotion.slow,
            curve: HrMotion.enter,
            builder: (context, value, _) => Stack(
              children: [
                Container(height: 8, color: Colors.white),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: HrColors.brandGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (bucket.pending > 0) ...[
          const SizedBox(height: 5),
          Text(
            '${bucket.pending.toStringAsFixed(0)} day(s) awaiting approval',
            style: const TextStyle(fontSize: 10.5, color: HrColors.warn),
          ),
        ],
      ],
    );
  }
}
