class RouteStop {
  final String name;
  RouteStop({required this.name});
}

class BusRoute {
  final String id;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final String estimatedDuration;
  final List<RouteStop> stops;
  final String? assignedBusId; // ADDED: Links Route to a Bus

  BusRoute({
    required this.id,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    required this.estimatedDuration,
    required this.stops,
    this.assignedBusId,
  });
}

class RouteData {
  static List<BusRoute> routes = [];

  static String generateRouteId() {
     return "RT${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  }
}