class Buyer {
  const Buyer({
    required this.energyEfficiency,
    required this.water,
    required this.resilience,
    required this.preference,
    required this.name,
  });
  final int energyEfficiency;
  final int water;
  final int resilience;
  final String name;
  final List<String> preference;
}
