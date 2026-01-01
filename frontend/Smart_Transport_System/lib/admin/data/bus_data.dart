class Bus {
  final String id;
  final String name;
  final String number;
  // REMOVED: capacity
  // Note: We don't necessarily store routeId here if Route stores busId, 
  // but keeping a link is useful. For now, we follow the "Route has Bus ID" rule.

  Bus({
    required this.id,
    required this.name,
    required this.number,
  });
}

class BusData {
  static List<Bus> buses = [];

  static String generateBusId() {
     return "BUS${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  }
}