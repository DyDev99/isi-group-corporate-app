import 'package:flutter/material.dart';

import '../../domain/entities/hr_category.dart';
import '../theme/hr_tokens.dart';

/// Horizontally swipeable scope filter. Selecting a scope re-filters the
/// suggested questions, the Knowledge Center and the retrieval itself.
class CategoryFilterBar extends StatelessWidget {
  final HrCategory selected;
  final ValueChanged<HrCategory> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: HrCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = HrCategory.values[index];
          final isSelected = category == selected;

          return GestureDetector(
            onTap: () => onSelected(category),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: HrMotion.base,
              curve: HrMotion.enter,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: isSelected ? HrColors.brandGradient : null,
                color: isSelected ? null : HrColors.surface,
                borderRadius: BorderRadius.circular(HrRadius.chip),
                border: Border.all(
                  color: isSelected ? Colors.transparent : HrColors.hairline,
                ),
                boxShadow:
                    isSelected ? HrShadows.brandGlow() : HrShadows.soft(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconForCategoryLabel(category.label),
                    size: 15,
                    color: isSelected ? Colors.white : HrColors.inkMuted,
                  ),
                  const SizedBox(width: 7),
                  AnimatedDefaultTextStyle(
                    duration: HrMotion.fast,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : HrColors.inkBody,
                    ),
                    child: Text(category.label),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
