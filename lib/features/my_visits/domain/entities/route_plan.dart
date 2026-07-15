class RoutePlan {
  final String id;
  final String name;
  final int completedStops;
  final List<String> stops;

  const RoutePlan({
    required this.id,
    required this.name,
    required this.completedStops,
    required this.stops,
  });
}
