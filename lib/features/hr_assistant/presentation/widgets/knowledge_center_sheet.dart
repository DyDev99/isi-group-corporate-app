import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/knowledge_doc.dart';
import '../bloc/hr_chat_bloc.dart';
import '../theme/hr_tokens.dart';
import 'category_filter_bar.dart';
import 'doc_viewer_sheet.dart';

/// Browse the corpus directly: filter by scope, search by title, code, owner
/// or summary, then open any document in the zoomable viewer.
Future<void> showKnowledgeCenter(BuildContext context, HrChatBloc bloc) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: HrColors.ink.withValues(alpha: 0.45),
    builder: (_) => BlocProvider<HrChatBloc>.value(
      value: bloc,
      child: const _KnowledgeCenterSheet(),
    ),
  );
}

class _KnowledgeCenterSheet extends StatefulWidget {
  const _KnowledgeCenterSheet();

  @override
  State<_KnowledgeCenterSheet> createState() => _KnowledgeCenterSheetState();
}

class _KnowledgeCenterSheetState extends State<_KnowledgeCenterSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<HrChatBloc>().state.knowledgeQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HrChatBloc>();

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: HrColors.canvas,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(HrRadius.sheet)),
        ),
        child: BlocBuilder<HrChatBloc, HrChatState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HrColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Knowledge Center',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: HrColors.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Every policy the assistant is allowed to quote.',
                              style: TextStyle(
                                fontSize: 12,
                                color: HrColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded,
                            color: HrColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: HrColors.surface,
                      borderRadius: BorderRadius.circular(HrRadius.chip),
                      border: Border.all(color: HrColors.hairline),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 18, color: HrColors.inkFaint),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => bloc
                                .add(HrChatKnowledgeQueryChanged(value)),
                            style: const TextStyle(
                                fontSize: 14, color: HrColors.ink),
                            decoration: const InputDecoration(
                              hintText: 'Search title, code or owner',
                              hintStyle: TextStyle(color: HrColors.inkFaint),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        if (state.knowledgeQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              bloc.add(const HrChatKnowledgeQueryChanged(''));
                            },
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: HrColors.inkMuted),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CategoryFilterBar(
                  selected: state.category,
                  onSelected: (category) =>
                      bloc.add(HrChatCategoryChanged(category)),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: state.docs.isEmpty
                      ? _empty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => _DocRow(
                            doc: state.docs[index],
                            onTap: () =>
                                showDocViewer(context, state.docs[index]),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 34, color: HrColors.inkFaint),
            const SizedBox(height: 12),
            const Text(
              'Nothing matches that search',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: HrColors.inkBody,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a broader scope, or ask the assistant directly.',
              style: TextStyle(fontSize: 12, color: HrColors.inkMuted),
            ),
          ],
        ),
      );
}

class _DocRow extends StatelessWidget {
  final KnowledgeDoc doc;
  final VoidCallback onTap;

  const _DocRow({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.circular(HrRadius.card),
          border: Border.all(color: HrColors.hairline),
          boxShadow: HrShadows.soft(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: HrColors.brandWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconForCategoryLabel(doc.category.label),
                size: 20,
                color: HrColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HrColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doc.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: HrColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _tag(doc.code),
                      const SizedBox(width: 6),
                      _tag('${doc.pageCount} pages'),
                      const SizedBox(width: 6),
                      _tag(doc.version),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: HrColors.inkFaint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: HrColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: HrColors.inkMuted,
          ),
        ),
      );
}
