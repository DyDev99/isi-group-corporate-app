import 'hr_category.dart';

/// One paragraph of a document, as rendered inside the zoomable viewer.
class DocParagraph {
  final String? heading;
  final String body;

  /// True when this paragraph is the passage the answer was grounded in.
  final bool cited;

  const DocParagraph({
    required this.body,
    this.heading,
    this.cited = false,
  });
}

/// A policy / SOP / handbook document in the HR knowledge base.
class KnowledgeDoc {
  final String id;
  final String code;
  final String title;
  final String summary;
  final String owner;
  final String version;
  final HrCategory category;
  final DateTime updatedAt;
  final int pageCount;
  final int citedPage;
  final double relevance;
  final List<DocParagraph> excerpt;

  const KnowledgeDoc({
    required this.id,
    required this.code,
    required this.title,
    required this.summary,
    required this.owner,
    required this.version,
    required this.category,
    required this.updatedAt,
    required this.pageCount,
    required this.excerpt,
    this.citedPage = 1,
    this.relevance = 0,
  });

  KnowledgeDoc copyWith({double? relevance, int? citedPage}) => KnowledgeDoc(
        id: id,
        code: code,
        title: title,
        summary: summary,
        owner: owner,
        version: version,
        category: category,
        updatedAt: updatedAt,
        pageCount: pageCount,
        excerpt: excerpt,
        citedPage: citedPage ?? this.citedPage,
        relevance: relevance ?? this.relevance,
      );
}
